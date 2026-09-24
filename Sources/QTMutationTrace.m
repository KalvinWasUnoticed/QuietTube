#import "QTCore.h"
#include <string.h>
#include "QTTemplateScan.h"
#include "QTFeedRules.h"

// Observation only. Bounded renderer reads on the observed insertion notification.
// No payload dumps, mutation suppression,
// error-pointer reads, retries of native operations or layout-enum assumptions.
static NSMutableArray<NSDictionary *> *QTTraceEvents;
static NSUInteger QTTraceTotals[9], QTTraceDropped, QTTraceOutside;
static BOOL QTTraceInstalled[9];
static NSTimeInterval QTTraceCollapse;
static BOOL QTTraceCompletionAnchor;
static NSUInteger QTTraceElementSamples;
static NSArray<NSString *> *QTTraceNames(void) {
    return @[@"willCollapse", @"didCollapse", @"layoutChanged", @"applyMutationOperation:error:",
      @"handleInsertSectionOperation:error:", @"handleInsertItemSectionContent:error:",
      @"handleReplaceSection:error:", @"handleReplaceItemSectionContent:error:", @"didInsertEntries:atIndexes:"];
}
static NSArray<NSString *> *QTTestFlags(void) {
    return @[@"enabled", @"adTest", @"feedAds", @"extendedFeed", @"displayAds", @"inspectElements", @"mutationTrace"];
}
void QTPrepareAdTest(void) {
    for (NSString *key in QTTestFlags()) QTSet(key, YES);
    // Do not reset current launch state/counters or silently activate hooks.
}
static void QTTracePrepare(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{ QTTraceEvents=[NSMutableArray array]; });
}
static NSString *QTTraceClass(id value) {
    return value ? NSStringFromClass(object_getClass(value)) : @"nil";
}
// Inspect only the exact entry class observed on device, at the notification
// boundary. Reuse existing signature-checked getters and bounded byte scanners.
// No serialization, object graph traversal or filtering decision here.
static NSString *QTTraceElement(id entry) {
    if (![QTTraceClass(entry) isEqualToString:@"YTIElementRenderer"]) return @"";
    if (QTTraceElementSamples>=6) return @" element-detail=sample-limit";
    QTTraceElementSamples++;
    BOOL compatibilityReadable=QTMatches(entry,NSSelectorFromString(@"compatibilityOptions"),@"@");
    id compatibility=compatibilityReadable?QTGet(entry,@"compatibilityOptions"):nil;
    BOOL adReadable=QTMatches(compatibility,NSSelectorFromString(@"hasAdLoggingData"),@"B");
    NSString *adFlag=adReadable?(QTBool(compatibility,@"hasAdLoggingData")?@"yes":@"no"):@"unavailable";
    BOOL dataReadable=QTMatches(entry,NSSelectorFromString(@"elementData"),@"@");
    id data=dataReadable?QTGet(entry,@"elementData"):nil;
    NSMutableString *s=[NSMutableString stringWithFormat:@" adLogging=%@",adFlag];
    if (![data isKindOfClass:NSData.class]) {
        [s appendFormat:@" elementData=%@",dataReadable?@"missing/non-data":@"getter-unavailable"];
        return s;
    }
    NSUInteger length=[data length];
    [s appendFormat:@" bytes=%lu",(unsigned long)length];
    if (!length || length>262144) { [s appendString:@" inspection-skipped(size)"]; return s; }
    unsigned kind=QTClassifyElementBytes([data bytes],length);
    [s appendFormat:@" existing-rule-mask=0x%x (observation only)",kind];
    char names[8][97]={{0}};
    size_t count=QTExtractTemplateNames([data bytes],length,names,8);
    [s appendString:@" template-candidates="];
    if (!count) [s appendString:@"none"];
    for (size_t i=0;i<count;i++) [s appendFormat:@"%s%s",i?",":"",names[i]];
    return s;
}
static NSString *QTTraceShape(id value, BOOL inspectEntry) {
    NSMutableString *s=[NSMutableString stringWithString:QTTraceClass(value)];
    if ([value isKindOfClass:NSArray.class]) {
        NSArray *a=value;
        [s appendFormat:@" count=%lu sampleClasses=",(unsigned long)a.count];
        for (NSUInteger i=0;i<MIN(a.count,(NSUInteger)3);i++) {
            [s appendFormat:@"%@%@",i?@",":@"",QTTraceClass(a[i])];
            if (inspectEntry) [s appendString:QTTraceElement(a[i])];
        }
    }
    return s;
}
static void QTTraceRecord(NSUInteger slot, id receiver, id argument, NSString *detail) {
    @try {
        QTTracePrepare();
        @synchronized(QTTraceEvents) {
            NSTimeInterval now=NSProcessInfo.processInfo.systemUptime;
            QTTraceTotals[slot]++;
            if (slot==0 || (slot==1 && (!QTTraceCollapse || now-QTTraceCollapse>12.0))) {
                // Start is preferred; completion is a fallback if start never ran.
                // Discard stale history from previous windows.
                while (QTTraceEvents.count && now-[QTTraceEvents.firstObject[@"time"] doubleValue]>12.0) {
                    [QTTraceEvents removeObjectAtIndex:0]; QTTraceDropped++;
                }
                // Keep up to 24 recent preceding events for ordering context.
                while (QTTraceEvents.count>24) { [QTTraceEvents removeObjectAtIndex:0]; QTTraceDropped++; }
                QTTraceCollapse=now;
                QTTraceCompletionAnchor=(slot==1);
                QTTraceElementSamples=0;
            }
            if (QTTraceCollapse && now-QTTraceCollapse>12.0) { QTTraceOutside++; return; }
            NSUInteger cap=QTTraceCollapse?96:24;
            if (QTTraceEvents.count>=cap) { [QTTraceEvents removeObjectAtIndex:0]; QTTraceDropped++; }
            [QTTraceEvents addObject:@{@"time":@(now), @"text":[NSString stringWithFormat:@"%@ receiver=%@ arg=%@ %@",QTTraceNames()[slot],QTTraceClass(receiver),QTTraceShape(argument,slot==8 && QTTraceCollapse>0),detail ?: @""]}];
        }
    } @catch (__unused NSException *exception) { /* Diagnostic failure never replaces native behavior. */ }
}
static void QTTraceHook(NSUInteger slot, NSString *clsName, NSString *selName, NSString *abi, id (^factory)(IMP,SEL)) {
    if (QTTraceInstalled[slot]) return;
    Class cls=NSClassFromString(clsName);
    SEL sel=NSSelectorFromString(selName);
    IMP before=cls?class_getMethodImplementation(cls,sel):NULL;
    // Compact signatures encode a pointer as one character; check pointee too.
    if (slot>=3 && slot<8) {
        Method method=cls?class_getInstanceMethod(cls,sel):NULL;
        if (!method) return;
        NSMethodSignature *sig=[NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
        if (sig.numberOfArguments!=4 || strcmp([sig getArgumentTypeAtIndex:3],"^@")!=0) return;
    }
    QTHook(clsName,selName,abi,factory);
    QTTraceInstalled[slot]=before && class_getMethodImplementation(cls,sel)!=before;
}
void QTInstallMutationTrace(void) {
    if (!QTOn(@"enabled") || !QTOn(@"mutationTrace")) return;
    QTTracePrepare();
    QTTraceHook(0,@"YTWatchLayerViewController",@"willCollapseWatchFlowWithAnimationStyle:",@"vQ",^id(IMP old,SEL sel) {
        return ^(id obj, long long style) {
            QTTraceRecord(0,obj,nil,[NSString stringWithFormat:@"enter style=%lld",style]);
            ((void(*)(id,SEL,long long))old)(obj,sel,style);
        };
    });
    QTTraceHook(1,@"YTWatchLayerViewController",@"didCollapseWatchFlowWithGestureType:",@"vi",^id(IMP old,SEL sel) {
        return ^(id obj, int gesture) {
            ((void(*)(id,SEL,int))old)(obj,sel,gesture);
            QTTraceRecord(1,obj,nil,[NSString stringWithFormat:@"returned gesture=%d",gesture]);
        };
    });
    QTTraceHook(2,@"YTAppWatchControllerImpl",@"handleWatchViewLayoutChangedFromLayout:toLayout:",@"vQQ",^id(IMP old,SEL sel) {
        return ^(id obj, long long from, long long to) {
            QTTraceRecord(2,obj,nil,[NSString stringWithFormat:@"enter layout=%lld->%lld (unmapped)",from,to]);
            ((void(*)(id,SEL,long long,long long))old)(obj,sel,from,to);
        };
    });
    for (NSUInteger slot=3;slot<8;slot++) {
        QTTraceHook(slot,@"YTInnerTubeCollectionViewController",QTTraceNames()[slot],@"@@^",^id(IMP old,SEL sel) {
            return ^id(id obj, id operation, NSError *__autoreleasing *error) {
                QTTraceRecord(slot,obj,operation,@"enter");
                return ((id(*)(id,SEL,id,NSError *__autoreleasing *))old)(obj,sel,operation,error);
            };
        });
    }
    QTTraceHook(8,@"YTArraySectionViewModel",@"didInsertEntries:atIndexes:",@"v@@",^id(IMP old,SEL sel) {
        return ^(id obj, id entries, id indexes) {
            QTTraceRecord(8,obj,entries,@"enter (native insert notification)");
            ((void(*)(id,SEL,id,id))old)(obj,sel,entries,indexes);
        };
    });
}
NSString *QTMutationReport(void) {
    QTTracePrepare();
    NSMutableString *s=[NSMutableString stringWithString:@"\nMINIMIZE / MUTATION OBSERVATION\nPrerequisites: current launch / saved next launch\n"];
    for (NSString *key in QTTestFlags())
        [s appendFormat:@"%@: %@ / %@\n",key,QTOn(key)?@"on":@"off",[NSUserDefaults.standardUserDefaults boolForKey:[@"QuietTube.v1." stringByAppendingString:key]]?@"on":@"off"];
    @synchronized(QTTraceEvents) {
        for (NSUInteger i=0;i<9;i++)
            [s appendFormat:@"%@: installed=%@ calls=%lu\n",QTTraceNames()[i],QTTraceInstalled[i]?@"yes":@"no",(unsigned long)QTTraceTotals[i]];
        [s appendFormat:@"Window anchor: %@. Times relative to that event, or first retained event if no anchor.\n",
            !QTTraceCollapse?@"NONE":QTTraceCompletionAnchor?@"collapse completion (start not observed in this window)":@"collapse start"];
        [s appendFormat:@"Element detail samples: %lu / 6 per window; max 3 entries/call, 8 template candidates/entry, 256 KiB/entry.\n",(unsigned long)QTTraceElementSamples];
        [s appendString:@"Template candidates are lexical clues, not decoded roots or a deletion verdict. No raw bytes/titles/URLs are printed.\n"];
        [s appendFormat:@"Up to 24 pre-events / 96 total; 12s window. Discarded=%lu; outside-window=%lu.\n",(unsigned long)QTTraceDropped,(unsigned long)QTTraceOutside];
        [s appendString:@"Calls are pass-through. Nearby events do not prove ad identity or causation. No monitored call does not mean no native mutation.\n"];
        NSTimeInterval anchor=QTTraceCollapse ?: [QTTraceEvents.firstObject[@"time"] doubleValue];
        for (NSDictionary *event in QTTraceEvents)
            [s appendFormat:@"%+.3fs %@\n",[event[@"time"] doubleValue]-anchor,event[@"text"]];
    }
    return s;
}
