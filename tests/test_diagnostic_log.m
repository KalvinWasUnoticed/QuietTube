#import "../Sources/QTDiagnosticLog.h"
#import "../Sources/QTDiagnosticPolicy.h"
#include <assert.h>
#include <stdio.h>
#include <unistd.h>
static NSString *Export(void) {
    dispatch_semaphore_t done=dispatch_semaphore_create(0);
    __block NSString *result;
    QTDExport(^(NSString *text) { result=text; dispatch_semaphore_signal(done); });
    assert(dispatch_semaphore_wait(done,dispatch_time(DISPATCH_TIME_NOW,15*NSEC_PER_SEC))==0);
    return result;
}
static void Clear(void) {
    dispatch_semaphore_t done=dispatch_semaphore_create(0);
    QTDClear(^{ dispatch_semaphore_signal(done); });
    assert(dispatch_semaphore_wait(done,dispatch_time(DISPATCH_TIME_NOW,15*NSEC_PER_SEC))==0);
}
static NSData *Line(NSTimeInterval time, NSDictionary *fields) {
    NSDictionary *row=@{@"at":@(time),@"event":@(QTDEElement),@"fields":fields};
    NSMutableData *data=[[NSJSONSerialization dataWithJSONObject:row options:0 error:NULL] mutableCopy];
    [data appendBytes:"\n" length:1]; return data;
}
static NSString *Path(NSString *root, NSUInteger index) { return [root stringByAppendingPathComponent:[NSString stringWithFormat:@"events-%lu.jsonl",(unsigned long)index]]; }
int main(int argc,const char *argv[]) {
    @autoreleasepool {
        assert(argc==2);
        NSString *root=[NSString stringWithUTF8String:argv[1]];
        QTDConfigure(root);
        assert(!QTDEnabled());
        NSString *off=Export(); assert(![off containsString:@"\"event\""]);
        QTDEvent(QTDEElement,@{@"code":@991});
        assert(![Export() containsString:@"991"]);
        NSDictionary *safe=QTDSanitize(@{@"token":@"PRIVATE_SECRET",@"url":@"https://private",@"class":@"YTIPlayableItemRenderer",@"template0":@"https://private",@"template1":@"playable_card.eml",@"count":@2,@"code":@"PRIVATE_SECRET",@"phase":@(INFINITY)});
        assert(safe.count==3); assert([safe[@"count"] integerValue]==2);
        assert(!safe[@"token"] && !safe[@"url"] && !safe[@"template0"] && !safe[@"phase"]);
        assert(QTDStart());
        QTDEvent(QTDEElement,@{@"class":@"YTIPlayableItemRenderer",@"template0":@"playable_card.eml",@"token":@"PRIVATE_SECRET"});
        dispatch_apply(1000,dispatch_get_global_queue(QOS_CLASS_USER_INITIATED,0),^(size_t i) { QTDEvent(QTDEMutation,@{@"slot":@(i%9)}); });
        NSError *inner=[NSError errorWithDomain:NSURLErrorDomain code:-1009 userInfo:@{NSLocalizedDescriptionKey:@"PRIVATE_SECRET"}];
        NSError *outer=[NSError errorWithDomain:@"private.account.domain" code:778899 userInfo:@{NSUnderlyingErrorKey:inner,NSLocalizedDescriptionKey:@"PRIVATE_SECRET"}];
        QTDError(outer); // Reserved capacity after ordinary-event flood.
        QTDStop(); assert(!QTDEnabled());
        NSString *report=Export();
        assert([report containsString:@"playable_card.eml"]);
        assert([report containsString:@"778899"] && [report containsString:@"-1009"]);
        assert(![report containsString:@"PRIVATE_SECRET"] && ![report containsString:@"private.account.domain"]);
        assert(![report containsString:@"Rate drops: 0."]);
        // After a drain, repeated exports are stable while recording is off.
        assert([report isEqualToString:Export()]);
        Clear(); assert(![Export() containsString:@"\"event\""]);
        NSFileManager *fm=NSFileManager.defaultManager;
        NSString *sentinel=[root stringByAppendingPathComponent:@"unrelated.txt"];
        assert([@"keep" writeToFile:sentinel atomically:YES encoding:NSUTF8StringEncoding error:NULL]);
        // Seed on-disk records only while writer is drained/stopped.
        assert([Line(NSDate.date.timeIntervalSince1970-604801,@{@"code":@987654}) writeToFile:Path(root,2) atomically:YES]);
        NSMutableData *corrupt=[Line(NSDate.date.timeIntervalSince1970,@{@"code":@12345,@"token":@"PRIVATE_SECRET",@"template0":@"https://private"}) mutableCopy];
        [corrupt appendData:[@"{broken SECRET_TRAILER" dataUsingEncoding:NSUTF8StringEncoding]];
        assert([corrupt writeToFile:Path(root,1) atomically:YES]);
        report=Export();
        assert(![report containsString:@"987654"] && [report containsString:@"12345"]);
        assert(![report containsString:@"PRIVATE_SECRET"] && ![report containsString:@"SECRET_TRAILER"] && ![report containsString:@"https://private"]);
        assert(![fm fileExistsAtPath:Path(root,2)]);
        Clear();
        assert([fm fileExistsAtPath:sentinel]);
        // Read failures must not turn into destructive "empty/corrupt" cleanup.
        if (geteuid()!=0) {
            assert([Line(NSDate.date.timeIntervalSince1970,@{@"code":@177225}) writeToFile:Path(root,0) atomically:YES]);
            assert([fm setAttributes:@{NSFilePosixPermissions:@0000} ofItemAtPath:Path(root,0) error:NULL]);
            (void)Export(); assert([fm fileExistsAtPath:Path(root,0)]);
            assert([fm setAttributes:@{NSFilePosixPermissions:@0600} ofItemAtPath:Path(root,0) error:NULL]);
            assert([Export() containsString:@"177225"]); Clear();
        }
        // Seed three nearly full files, then force rollover with large safe records.
        NSString *identifier=[@"video_" stringByPaddingToLength:96 withString:@"x" startingAtIndex:0];
        NSDictionary *fields=@{@"template0":identifier,@"template1":identifier,@"template2":identifier,@"template3":identifier,@"class":@"YTIElementRenderer"};
        NSData *line=Line(NSDate.date.timeIntervalSince1970,fields);
        NSMutableData *full=[NSMutableData data];
        while (QTDPFits(full.length,line.length)) [full appendData:line];
        for (NSUInteger i=0;i<3;i++) assert([full writeToFile:Path(root,i) atomically:YES]);
        assert(QTDStart());
        for(NSUInteger i=0;i<10;i++) QTDEvent(QTDEElement,fields);
        QTDStop(); (void)Export();
        unsigned long long total=0;
        for(NSUInteger i=0;i<3;i++) {
            unsigned long long size=[[fm attributesOfItemAtPath:Path(root,i) error:NULL][NSFileSize] unsignedLongLongValue];
            assert(size<=QTDPFileLimit); total+=size;
        }
        assert(total<=3ULL*QTDPFileLimit);
        Clear(); assert([fm fileExistsAtPath:sentinel]);
        assert([fm contentsOfDirectoryAtPath:root error:NULL].count==1);
        // Disk failure must not throw into the caller or pretend success in export.
        assert([fm removeItemAtPath:root error:NULL]);
        assert([@"not a directory" writeToFile:root atomically:YES encoding:NSUTF8StringEncoding error:NULL]);
        assert(QTDStart()); QTDEvent(QTDEMutation,@{@"slot":@1}); QTDStop();
        assert(![Export() containsString:@"Storage failures: 0."]);
        puts("Native logger: off/start/stop, schema redaction, 1000 concurrent calls, error reserve, stable export, expiry/corruption, rotation bounds, clear ordering and storage failure passed. Not device hook execution.");
    }
    return 0;
}
