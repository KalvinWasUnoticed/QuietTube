// Execute the real observer against mock native getters; not real YouTube hooks.
#import "../Sources/QTObservationAccess.h"
#import "../Sources/QTDiagnosticsBridge.h"
#import "../Sources/QTDiagnosticLog.h"
#import <objc/message.h>
#include <assert.h>
#include <stdio.h>
static NSUInteger reads;
BOOL QTMatches(id object,SEL selector,NSString *signature) {
    if (![object respondsToSelector:selector]) return NO;
    NSMethodSignature *sig=[object methodSignatureForSelector:selector];
    char actual=sig.methodReturnType[0]; if(actual=='c')actual='B';
    return sig.numberOfArguments==2 && actual==[signature characterAtIndex:0];
}
id QTGet(id object,NSString *name) {
    reads++; SEL sel=NSSelectorFromString(name);
    if(!QTMatches(object,sel,@"@"))return nil;
    @try { return ((id(*)(id,SEL))objc_msgSend)(object,sel); }
    @catch (__unused NSException *error) { return nil; }
}
BOOL QTBool(id object,NSString *name) {
    reads++; SEL sel=NSSelectorFromString(name);
    if(!QTMatches(object,sel,@"B"))return NO;
    return ((BOOL(*)(id,SEL))objc_msgSend)(object,sel);
}
@interface YTITestCompatibility : NSObject
@end
@implementation YTITestCompatibility
- (BOOL)hasAdLoggingData { return YES; }
@end
@interface YTIElementRenderer : NSObject
@property(nonatomic,strong) NSData *data;
@end
@implementation YTIElementRenderer
- (id)compatibilityOptions { return [YTITestCompatibility new]; }
- (id)elementData { return self.data; }
@end
@interface YTIThrowElementRenderer : YTIElementRenderer
@end
@implementation YTIThrowElementRenderer
- (id)elementData { @throw [NSException exceptionWithName:@"test" reason:@"PRIVATE_SECRET" userInfo:nil]; }
@end
static NSString *Export(void) {
    dispatch_semaphore_t done=dispatch_semaphore_create(0); __block NSString *result;
    QTDExport(^(NSString *text){ result=text;dispatch_semaphore_signal(done); });
    assert(dispatch_semaphore_wait(done,dispatch_time(DISPATCH_TIME_NOW,15*NSEC_PER_SEC))==0);
    return result;
}
int main(int argc,const char *argv[]) {
    @autoreleasepool {
        assert(argc==2); QTDConfigure([NSString stringWithUTF8String:argv[1]]);
        YTIElementRenderer *entry=[YTIElementRenderer new];
        entry.data=[@"playable_card.eml PRIVATE_SECRET" dataUsingEncoding:NSUTF8StringEncoding];
        NSData *before=[entry.data copy];
        QTDDiagnosticBoundary(entry,@[entry],0); assert(reads==0); // Off path is inert.
        assert(QTDStart());
        QTDDiagnosticBoundary(entry,@[entry],0); QTDStop();
        NSString *report=Export();
        assert([report containsString:@"playable_card.eml"] && ![report containsString:@"PRIVATE_SECRET"]);
        assert([entry.data isEqualToData:before]); assert(reads<=80);
        assert([report containsString:@"\"ad\":1"] && [report containsString:@"\"mask\":4"]);
        // Oversized data is measured but never scanned; throw/nil getters pass through.
        assert(QTDStart());
        entry.data=[NSMutableData dataWithLength:262145];
        reads=0; QTDDiagnosticBoundary(entry,@[entry],0); QTDStop();
        assert(reads<=80); assert([Export() containsString:@"262145"]);
        assert(QTDStart());
        QTDDiagnosticBoundary(nil,@[[YTIThrowElementRenderer new]],0);
        QTDDiagnosticBoundary(nil,nil,0);
        QTDDiagnosticMutation(8,entry,@[entry]);
        QTDDiagnosticPlayer(@"player factory called");
        QTDDiagnosticPlayer(@"unrecognized PRIVATE_SECRET");
        QTDStop(); assert(![Export() containsString:@"PRIVATE_SECRET"]);
        puts("Native observer: inert off path, Playables/ad clues, immutable payload, bounded getters, oversize/nil/throwing inputs and player/mutation calls passed against mocks. Not YouTube execution.");
    }
    return 0;
}
