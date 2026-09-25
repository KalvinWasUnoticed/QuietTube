#import "QTCore.h"
#import "QTDiagnosticLog.h"
#import "QTDiagnosticsBridge.h"
#include <string.h>
#include "QTInsertionPolicy.h"

// Two hooks, one transaction scope. No global array/getter filtering and no
// notification suppression after a view model has already changed.
static BOOL QTFeedHandlerInstalled, QTFeedArrayInstalled;
static _Thread_local NSUInteger QTFeedScopeDepth;
static NSObject *QTFeedLock;
static unsigned long long QTFeedTotals[8];
enum { QTFeedHandlerCalls, QTFeedScopedCalls, QTFeedMatched, QTFeedCompletedBatches,
       QTFeedWithheld, QTFeedKept, QTFeedFallbacks, QTFeedOversize };
static void QTFeedPrepare(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{ QTFeedLock=[NSObject new]; });
}
static void QTFeedAdd(NSUInteger metric, NSUInteger amount) {
    QTFeedPrepare();
    @synchronized(QTFeedLock) { QTFeedTotals[metric]+=amount; }
}
BOOL QTFeedInsertionHandlerInstalled(void) { return QTFeedHandlerInstalled; }
static BOOL QTFeedExactABI(NSString *name, NSString *selector, const char *types) {
    Class cls=NSClassFromString(name);
    Method m=cls?class_getInstanceMethod(cls,NSSelectorFromString(selector)):NULL;
    return m && strcmp(method_getTypeEncoding(m),types)==0;
}
static id QTFeedFilteredEntries(id entries, NSUInteger *removed, NSUInteger *keptCount) {
    *removed=0; *keptCount=0;
    @try {
        if (![entries isKindOfClass:NSArray.class]) return entries;
        NSArray *array=entries;
        if (!array.count) return entries;
        if (!QTInsertionBatchWithinLimit(array.count)) { QTFeedAdd(QTFeedOversize,1); return entries; }
        NSMutableArray *kept=[NSMutableArray arrayWithCapacity:array.count];
        NSUInteger rejected=0;
        for (id entry in array) {
            // Exact device-observed element class + explicit protobuf presence
            // marker, already used by the accepted feed filter. Unknowns pass.
            BOOL exact=[NSStringFromClass(object_getClass(entry)) isEqualToString:@"YTIElementRenderer"];
            BOOL ad=QTInsertionRejectEntry(exact,exact &&
                QTBool(QTGet(entry,@"compatibilityOptions"),@"hasAdLoggingData"));
            if (ad) rejected++;
            else [kept addObject:entry];
        }
        if (!rejected) return entries; // Preserve array identity if unchanged.
        id result=[kept copy]; // Never mutate the native array or its entries.
        *removed=rejected;
        *keptCount=kept.count;
        return result; // Empty is a verified native no-op at this boundary.
    } @catch (__unused NSException *exception) {
        *removed=0; *keptCount=0;
        QTFeedAdd(QTFeedFallbacks,1);
        return entries;
    }
}
BOOL QTInstallFeedInsertion(void) {
    QTFeedPrepare();
    if (!QTFeedHandlerInstalled && QTFeedExactABI(@"YTInnerTubeCollectionViewController",
            @"handleInsertItemSectionContent:error:","@32@0:8@16^@24")) {
        Class cls=NSClassFromString(@"YTInnerTubeCollectionViewController");
        SEL sel=NSSelectorFromString(@"handleInsertItemSectionContent:error:");
        IMP before=class_getMethodImplementation(cls,sel);
        QTHook(@"YTInnerTubeCollectionViewController",@"handleInsertItemSectionContent:error:",@"@@^",^id(IMP old,SEL selector) {
            return ^id(id object,id operation,NSError *__autoreleasing *error) {
                QTTraceFeedInsertion(object,operation);
                QTFeedAdd(QTFeedHandlerCalls,1);
                NSUInteger previous=QTFeedScopeDepth;
                Class app=NSClassFromString(@"YTAppCollectionViewController");
                BOOL active=QTAdProfileActive() && QTOn(@"feedAds") && app && [object isKindOfClass:app];
                QTFeedScopeDepth=active?previous+1:0;
                @try {
                    // Original operation, result and error pointer; exactly once.
                    return ((id(*)(id,SEL,id,NSError *__autoreleasing *))old)(object,selector,operation,error);
                } @finally {
                    // Restore even on exceptions and nested unrelated handlers.
                    QTFeedScopeDepth=previous;
                }
            };
        });
        QTFeedHandlerInstalled=class_getMethodImplementation(cls,sel)!=before;
    }
    if (!QTFeedArrayInstalled && QTFeedExactABI(@"YTArraySectionViewModel",
            @"insertEntries:atIndex:","v32@0:8@16Q24")) {
        Class cls=NSClassFromString(@"YTArraySectionViewModel");
        SEL sel=NSSelectorFromString(@"insertEntries:atIndex:");
        IMP before=class_getMethodImplementation(cls,sel);
        QTHook(@"YTArraySectionViewModel",@"insertEntries:atIndex:",@"v@Q",^id(IMP old,SEL selector) {
            return ^(id object,id entries,NSUInteger index) {
                QTDDiagnosticBoundary(object,entries,1);
                id forwarded=entries;
                NSUInteger removed=0,kept=0;
                if (QTFeedScopeDepth && QTInsertionMayFilter(QTAdProfileActive(),QTOn(@"feedAds"),QTFeedScopeDepth)) {
                    QTFeedAdd(QTFeedScopedCalls,1);
                    forwarded=QTFeedFilteredEntries(entries,&removed,&kept);
                    if (removed) QTFeedAdd(QTFeedMatched,removed);
                }
                // Native empty-array branch returns without storage/index changes.
                // Native exceptions propagate; never retry this operation.
                ((void(*)(id,SEL,id,NSUInteger))old)(object,selector,forwarded,index);
                QTDEvent(QTDEFeedBoundary,@{@"phase":@2,@"removed":@(removed),@"kept":@(kept),@"scope":@(QTFeedScopeDepth)});
                if (removed) {
                    QTFeedAdd(QTFeedCompletedBatches,1);
                    QTFeedAdd(QTFeedWithheld,removed);
                    QTFeedAdd(QTFeedKept,kept);
                }
            };
        });
        QTFeedArrayInstalled=class_getMethodImplementation(cls,sel)!=before;
    }
    return QTFeedHandlerInstalled && QTFeedArrayInstalled;
}
NSString *QTFeedInsertionReport(void) {
    QTFeedPrepare();
    NSMutableString *s=[NSMutableString stringWithFormat:@"\nSCOPED FEED INSERTION FILTER\nHandler hook installed: %@; array-boundary hook installed: %@\nRequested active now: %@ (ad profile, safety latch and feedAds)\nRetired companion hook: not installed.\n",
        QTFeedHandlerInstalled?@"yes":@"no",QTFeedArrayInstalled?@"yes":@"no",
        QTAdProfileActive() && QTOn(@"feedAds")?@"yes":@"no"];
    @synchronized(QTFeedLock) {
        [s appendFormat:@"Handler calls: %llu; scoped array calls: %llu\nExplicit-marked entries matched: %llu\nFiltered native array calls returned: %llu\nEntries withheld on returned calls: %llu; unmarked entries forwarded in those calls: %llu\nPreparation fallbacks: %llu; oversized batches passed through: %llu\n",
            QTFeedTotals[QTFeedHandlerCalls],QTFeedTotals[QTFeedScopedCalls],QTFeedTotals[QTFeedMatched],
            QTFeedTotals[QTFeedCompletedBatches],QTFeedTotals[QTFeedWithheld],QTFeedTotals[QTFeedKept],
            QTFeedTotals[QTFeedFallbacks],QTFeedTotals[QTFeedOversize]];
        if (!QTFeedTotals[QTFeedWithheld]) [s appendString:@"FEED BLOCKING NOT DEMONSTRATED: no entries withheld on a returned native array call.\n"];
    }
    [s appendString:@"Filtering is scoped to synchronous app-collection item-content insertion, not a timer/gesture guess. Unknown/unmarked elements pass. Completed calls are not proof that all visible cards are gone.\n"];
    return s;
}
