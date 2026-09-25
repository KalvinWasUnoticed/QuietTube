#import "QTObservationAccess.h"
#import "QTDiagnosticLog.h"
#import "QTDiagnosticsBridge.h"
#include "QTFeedRules.h"
#include "QTTemplateScan.h"
static NSString *QTDClass(id value) { return value?NSStringFromClass(object_getClass(value)):@""; }
static void QTDInspectElement(id node) {
    if (![QTDClass(node) hasPrefix:@"YTI"] || ![QTDClass(node) hasSuffix:@"ElementRenderer"] || !QTDSample()) return;
    id compatibility=QTGet(node,@"compatibilityOptions");
    NSInteger ad=QTMatches(compatibility,NSSelectorFromString(@"hasAdLoggingData"),@"B") ? (QTBool(compatibility,@"hasAdLoggingData")?1:0) : -1;
    NSMutableDictionary *fields=[@{@"class":QTDClass(node),@"ad":@(ad)} mutableCopy];
    id data=QTGet(node,@"elementData");
    if ([data isKindOfClass:NSData.class]) {
        fields[@"bytes"]=@([data length]);
        if ([data length]<=262144) {
            fields[@"mask"]=@(QTClassifyElementBytes([data bytes],[data length]));
            char names[4][97]={{0}};
            size_t count=QTExtractTemplateNames([data bytes],[data length],names,4);
            for (size_t i=0;i<count;i++) fields[[NSString stringWithFormat:@"template%lu",(unsigned long)i]]=[NSString stringWithUTF8String:names[i]];
        }
    }
    QTDEvent(QTDEElement,fields);
}
// Closed, bounded observation only. No KVC, serialization, title/URL getters,
// config-value dumps, native mutation, filtering, retry or returned-object replacement.
static void QTDWalk(id value, NSUInteger depth, NSUInteger *budget) {
    if (!value || !*budget || depth>3) return;
    (*budget)--;
    if ([value isKindOfClass:NSArray.class]) {
        NSArray *array=value;
        for (NSUInteger i=0;i<MIN(array.count,(NSUInteger)3);i++) QTDWalk(array[i],depth+1,budget);
        return;
    }
    QTDEvent(QTDEFeedBoundary,@{@"class":QTDClass(value),@"depth":@(depth)});
    QTDInspectElement(value);
    for (NSString *key in @[@"contentsArray",@"itemsArray",@"itemSectionRenderer",@"elementRenderer",@"shelfRenderer",@"content"])
        if (*budget) { id child=QTGet(value,key); if (child!=value) QTDWalk(child,depth+1,budget); }
}
void QTDDiagnosticBoundary(id receiver, id argument, NSUInteger phase) {
    if (!QTDEnabled()) return;
    @try {
        QTDEvent(QTDEFeedBoundary,@{@"class":QTDClass(receiver),@"argumentClass":QTDClass(argument),@"phase":@(phase),@"count":@([argument isKindOfClass:NSArray.class]?[argument count]:0)});
        // One traversal per sampling admission; at most four admissions/second
        // shared with payload inspection. Exhausted samples retain boundary metadata.
        if (QTDSample()) { NSUInteger budget=12; QTDWalk(argument,0,&budget); }
    } @catch (__unused NSException *exception) { }
}
void QTDDiagnosticMutation(NSUInteger slot, id receiver, id argument) {
    if (!QTDEnabled()) return;
    @try {
        QTDEvent(QTDEMutation,@{@"slot":@(slot),@"class":QTDClass(receiver),@"argumentClass":QTDClass(argument),@"count":@([argument isKindOfClass:NSArray.class]?[argument count]:0)});
        if (slot>=3) QTDDiagnosticBoundary(receiver,argument,slot==8?2:1);
    } @catch (__unused NSException *exception) { }
}
void QTDDiagnosticPlayer(NSString *event) {
    if (!QTDEnabled()) return;
    @try {
        NSInteger phase=-1;
        if ([event isEqualToString:@"player factory called"]) phase=0;
        else if ([event isEqualToString:@"native no-op coordinator supplied"]) phase=1;
        else if ([event hasPrefix:@"SESSION SAFETY PAUSE"]) phase=2;
        else if ([event containsString:@"fallback"]) phase=3;
        if (phase>=0) QTDEvent(QTDEPlayer,@{@"phase":@(phase)});
    } @catch (__unused NSException *exception) { }
}
