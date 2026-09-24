#import "QTCore.h"
#include <stdatomic.h>
#include <stdbool.h>
#include <string.h>
#include "QTAdState.h"

// A typed initializer keeps ARC's init-family ownership rules. Never use -init.
@protocol QTNativeNoOpInitializer <NSObject>
- (instancetype)initWithServiceRegistryScope:(id)scope delegate:(id)delegate;
@end
static atomic_bool QTAdTripped = false;
static BOOL QTPlayerProfileInstalled, QTFeedProfileInstalled;
static NSMutableArray<NSString *> *QTAdEvents;
static NSMutableDictionary<NSString *,NSNumber *> *QTAdTotals;
static NSTimeInterval QTAdEpoch;
static NSUInteger QTAdDiscarded;
static void QTAdPrepare(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        QTAdEvents = [NSMutableArray array];
        QTAdTotals = [NSMutableDictionary dictionary];
        QTAdEpoch = NSProcessInfo.processInfo.systemUptime;
    });
}
static void QTAdRecord(NSString *event) {
    @try {
        QTAdPrepare();
        @synchronized(QTAdEvents) {
            QTAdTotals[event] = @([QTAdTotals[event] unsignedLongLongValue]+1);
            if (QTAdEvents.count>=80) { [QTAdEvents removeObjectAtIndex:0]; QTAdDiscarded++; }
            [QTAdEvents addObject:[NSString stringWithFormat:@"+%.1fs %@",NSProcessInfo.processInfo.systemUptime-QTAdEpoch,event]];
        }
    } @catch (__unused NSException *exception) { }
}
static BOOL QTAdActive(void) {
    return QTOn(@"adTest") && !atomic_load(&QTAdTripped);
}
// Count only numeric errors and allowlisted domain categories; no localized
// descriptions, signed URLs, userInfo dump, account IDs or response payloads.
void QTAdPlaybackError(NSError *error) {
    if (!QTOn(@"adTest")) return;
    if (!atomic_exchange(&QTAdTripped,true)) {
        @try { QTSet(@"adTest",NO); }
        @catch (__unused NSException *exception) { QTAdRecord(@"could not save profile OFF — disable manually before restart"); }
        QTAdRecord(@"SAFETY STOP: native behavior for future calls; profile saved OFF; restart required");
    }
    @try {
        QTAdPrepare();
        @synchronized(QTAdEvents) {
            NSError *current = error;
            for (NSUInteger depth=0;depth<3 && [current isKindOfClass:NSError.class];depth++) {
                NSString *kind = @"other";
                if ([current.domain isEqualToString:@"com.google.ios.youtube.ErrorDomain.playback"]) kind=@"YouTube";
                else if ([current.domain isEqualToString:NSURLErrorDomain]) kind=@"URL";
                else if ([current.domain isEqualToString:NSCocoaErrorDomain]) kind=@"Cocoa";
                else if ([current.domain isEqualToString:NSOSStatusErrorDomain]) kind=@"OSStatus";
                // Error details go only to the bounded event ring, not dictionary keys.
                if (QTAdEvents.count>=80) { [QTAdEvents removeObjectAtIndex:0]; QTAdDiscarded++; }
                [QTAdEvents addObject:[NSString stringWithFormat:@"+%.1fs error depth %lu %@ code %ld",NSProcessInfo.processInfo.systemUptime-QTAdEpoch,(unsigned long)depth,kind,(long)current.code]];
                id underlying = current.userInfo[NSUnderlyingErrorKey];
                if (underlying==current) break;
                current = underlying;
            }
        }
    } @catch (__unused NSException *exception) { }
}
NSString *QTAdReport(void) {
    QTAdPrepare();
    QTAdInstallState state=QTAdState(QTOn(@"enabled"),QTOn(@"adTest"),atomic_load(&QTAdTripped),QTPlayerProfileInstalled,QTFeedProfileInstalled);
    NSMutableString *s=[NSMutableString stringWithFormat:@"QUIETTUBE 0.13.1 AD TEST REPORT\nProfile requested this launch: %@\nInstallation state: %s\nSaved for next launch: %@\nBoth workarounds share this one switch. Old branch preferences are ignored.\nPlayer hook installed: %@; feed hook installed: %@\n",
        QTOn(@"adTest")?@"on":@"off",QTAdStateName(state),
        [NSUserDefaults.standardUserDefaults boolForKey:@"QuietTube.v1.adTest"]?@"on":@"off",
        QTPlayerProfileInstalled?@"yes":@"no",QTFeedProfileInstalled?@"yes":@"no"];
    @synchronized(QTAdEvents) {
        unsigned long long calls=[QTAdTotals[@"player factory called"] unsignedLongLongValue];
        unsigned long long supplied=[QTAdTotals[@"native no-op coordinator supplied"] unsignedLongLongValue];
        unsigned long long feed=[QTAdTotals[@"watch-while feed mutation disabled"] unsignedLongLongValue];
        [s appendFormat:@"Player invocation: %llu calls; %llu native no-op objects supplied.\nFeed invocation: %llu disabled-feature reads.\n",calls,supplied,feed];
        if (!supplied) [s appendString:@"PLAYER BLOCKING NOT DEMONSTRATED: no no-op substitution recorded.\n"];
        if (!feed) [s appendString:@"FEED WORKAROUND NOT OBSERVED: no feature read recorded.\n"];
        [s appendString:@"Installation/invocation does not prove ad removal. Safety stop requires restart for existing players.\n\n"];
        for (NSString *key in [[QTAdTotals allKeys] sortedArrayUsingSelector:@selector(compare:)])
            [s appendFormat:@"%@ : %@\n",key,QTAdTotals[key]];
        [s appendFormat:@"\nLast %lu events (older discarded: %lu)\n",(unsigned long)QTAdEvents.count,(unsigned long)QTAdDiscarded];
        for (NSString *event in QTAdEvents) [s appendFormat:@"%@\n",event];
    }
    [s appendString:@"\nEND AD TEST REPORT\n\n"];
    return s;
}
void QTInstallAdProfile(void) {
    if (!QTAdActive()) return;
    QTAdPrepare();
    // Persistent success flags distinguish scheduled retries from failed installs.
    if (!QTFeedProfileInstalled) {
        Class cls=NSClassFromString(@"YTHotConfig");
        SEL sel=NSSelectorFromString(@"enableWatchWhileFeedMutationOnIos");
        IMP before=cls?class_getMethodImplementation(cls,sel):NULL;
        QTHook(@"YTHotConfig",@"enableWatchWhileFeedMutationOnIos",@"B",^id(IMP old,SEL selector) {
            return ^BOOL(id object) {
                if (QTAdActive()) { QTAdRecord(@"watch-while feed mutation disabled"); return NO; }
                return ((BOOL (*)(id,SEL))old)(object,selector);
            };
        });
        QTFeedProfileInstalled=cls && class_getMethodImplementation(cls,sel)!=before;
        QTAdRecord(QTFeedProfileInstalled?@"feed mutation hook installed":@"feed mutation hook unavailable — native unchanged");
    }
    if (!QTPlayerProfileInstalled) {
        Class factoryClass=NSClassFromString(@"YTRealAdsPlayerServices");
        Class noOpClass=NSClassFromString(@"YTNoOpAdsPlaybackCoordinator");
        Ivar scopeIvar=factoryClass?class_getInstanceVariable(factoryClass,"_serviceRegistryScope"):NULL;
        Method initializer=noOpClass?class_getInstanceMethod(noOpClass,NSSelectorFromString(@"initWithServiceRegistryScope:delegate:")):NULL;
        const char *ivarType=scopeIvar?ivar_getTypeEncoding(scopeIvar):NULL;
        if (!initializer || !ivarType || ivarType[0]!='@' || strcmp(method_getTypeEncoding(initializer),"@32@0:8@16@24")) {
            QTAdRecord(@"native constructor or scope ABI unavailable — native unchanged");
            return;
        }
        SEL sel=NSSelectorFromString(@"adsPlaybackCoordinatorWithOverlayManager:delegate:parentResponder:contentPlayerResponse:");
        IMP before=class_getMethodImplementation(factoryClass,sel);
        QTHook(@"YTRealAdsPlayerServices",@"adsPlaybackCoordinatorWithOverlayManager:delegate:parentResponder:contentPlayerResponse:",@"@@@@@",^id(IMP old,SEL selector) {
            return ^id(id object,id overlay,id delegate,id parent,id response) {
                if (QTAdActive()) {
                    QTAdRecord(@"player factory called");
                    id result=nil;
                    @try {
                        id scope=object_getIvar(object,scopeIvar);
                        if (scope && delegate) {
                            // Same verified native constructor, scope and delegate.
                            // Does not depend on a player response/config existing yet.
                            result=[(id<QTNativeNoOpInitializer>)[noOpClass alloc] initWithServiceRegistryScope:scope delegate:delegate];
                        } else QTAdRecord(@"missing scope or delegate — original factory fallback");
                    } @catch (__unused NSException *exception) {
                        QTAdRecord(@"native no-op construction exception — original factory fallback");
                    }
                    if (result && [result isKindOfClass:noOpClass]) {
                        QTAdRecord(@"native no-op coordinator supplied");
                        return result;
                    }
                    QTAdRecord(@"no valid no-op coordinator — original factory fallback");
                }
                // No retries or nil substitution. Native exceptions remain visible.
                return ((id (*)(id,SEL,id,id,id,id))old)(object,selector,overlay,delegate,parent,response);
            };
        });
        QTPlayerProfileInstalled=class_getMethodImplementation(factoryClass,sel)!=before;
        QTAdRecord(QTPlayerProfileInstalled?@"player factory hook installed":@"player factory hook unavailable — native unchanged");
    }
}
