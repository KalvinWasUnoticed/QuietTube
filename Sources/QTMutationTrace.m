#import "QTCore.h"
#include <string.h>

// Observation only. No renderer getters, payload dumps, mutation suppression,
// error-pointer reads, retries of native operations or layout-enum assumptions.
static NSMutableArray<NSDictionary *> *QTTraceEvents;
static NSUInteger QTTraceTotals[9], QTTraceDropped, QTTraceOutside;
static BOOL QTTraceInstalled[9];
static NSTimeInterval QTTraceCollapse;
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
static NSString *QTTraceShape(id value) {
    NSMutableString *s=[NSMutableString stringWithString:QTTraceClass(value)];
    if ([value isKindOfClass:NSArray.class]) {
        NSArray *a=value;
        [s appendFormat:@" count=%lu sampleClasses=",(unsigned long)a.count];
        for (NSUInteger i=0;i<MIN(a.count,(NSUInteger)3);i++)
            [s appendFormat:@"%@%@",i?@",":@"",QTTraceClass(a[i])];
    }
    return s;
}
static void QTTraceRecord(NSUInteger slot, id receiver, id argument, NSString *detail) {
    @try {
        QTTracePrepare();
        @synchronized(QTTraceEvents) {
            NSTimeInterval now=NSProcessInfo.processInfo.systemUptime;
            QTTraceTotals[slot]++;
            if (slot==0) {
                // Keep up to 24 immediately preceding events for ordering context.
                while (QTTraceEvents.count>24) { [QTTraceEvents removeObjectAtIndex:0]; QTTraceDropped++; }
                QTTraceCollapse=now;
            }
            if (QTTraceCollapse && now-QTTraceCollapse>12.0) { QTTraceOutside++; return; }
            NSUInteger cap=QTTraceCollapse?96:24;
            if (QTTraceEvents.count>=cap) { [QTTraceEvents removeObjectAtIndex:0]; QTTraceDropped++; }
            [QTTraceEvents addObject:@{@"time":@(now), @"text":[NSString stringWithFormat:@"%@ receiver=%@ arg=%@ %@",QTTraceNames()[slot],QTTraceClass(receiver),QTTraceShape(argument),detail ?: @""]}];
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
    QTTraceHook(0,@"YTWatchLayerViewController",@"willCollapseWatchFlowWithAnimationStyle:",@"vq",^id(IMP old,SEL sel) {
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
    QTTraceHook(2,@"YTAppWatchControllerImpl",@"handleWatchViewLayoutChangedFromLayout:toLayout:",@"vqq",^id(IMP old,SEL sel) {
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
        [s appendFormat:@"Collapse start observed: %@. Times relative to most recent observed start.\n",QTTraceCollapse?@"yes":@"NO"];
        [s appendFormat:@"Up to 24 pre-events / 96 total; 12s window. Discarded=%lu; outside-window=%lu.\n",(unsigned long)QTTraceDropped,(unsigned long)QTTraceOutside];
        [s appendString:@"Calls are pass-through. Nearby events do not prove ad identity or causation. No monitored call does not mean no native mutation.\n"];
        NSTimeInterval anchor=QTTraceCollapse ?: [QTTraceEvents.firstObject[@"time"] doubleValue];
        for (NSDictionary *event in QTTraceEvents)
            [s appendFormat:@"%+.3fs %@\n",[event[@"time"] doubleValue]-anchor,event[@"text"]];
    }
    return s;
}
