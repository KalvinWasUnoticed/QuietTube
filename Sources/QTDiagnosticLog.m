#import "QTDiagnosticLog.h"
#import <TargetConditionals.h>
#include <math.h>
#include "QTDiagnosticPolicy.h"

static NSObject *QTDLock;
static dispatch_queue_t QTDQueue;
static NSString *QTDDirectory;
static BOOL QTDRecording, QTDConfigured;
static NSUInteger QTDPending, QTDQueueDrops, QTDRateDrops, QTDFailures;
static NSUInteger QTDRateCount, QTDSamples;
static NSTimeInterval QTDRateWindow, QTDSampleWindow;
static const NSUInteger QTDFileLimit=QTDPFileLimit;
static NSTimeInterval QTDLastPrune;
static NSString * const QTEnhancedKey = @"QuietTube.v1.enhancedLogging";
static void QTDPrepare(void) {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        QTDLock=[NSObject new];
        QTDQueue=dispatch_queue_create("QuietTube.diagnostics",DISPATCH_QUEUE_SERIAL);
    });
}
static BOOL QTDIdentifier(NSString *value, BOOL selector) {
    if (![value isKindOfClass:NSString.class] || !value.length || value.length>96) return NO;
    for (NSUInteger i=0;i<value.length;i++) {
        unichar c=[value characterAtIndex:i];
        if (!((c>='a'&&c<='z') || (c>='A'&&c<='Z') || (c>='0'&&c<='9') || c=='_' || c=='.' || c=='-' || (selector&&c==':'))) return NO;
    }
    return YES;
}
NSDictionary *QTDSanitize(NSDictionary *fields) {
    NSMutableDictionary *safe=[NSMutableDictionary dictionary];
    if (![fields isKindOfClass:NSDictionary.class]) return safe;
    for (NSString *key in @[@"count",@"index",@"bytes",@"mask",@"ad",@"scope",@"code",@"depth",@"domain",@"phase",@"slot",@"installed",@"removed",@"kept"]) {
        id value=fields[key];
        if ([value isKindOfClass:NSNumber.class] && isfinite([value doubleValue]) && fabs([value doubleValue])<=9007199254740991.0) safe[key]=@([value longLongValue]);
    }
    for (NSString *key in @[@"class",@"argumentClass",@"selector",@"template0",@"template1",@"template2",@"template3"]) {
        id value=fields[key];
        if (!QTDIdentifier(value,[key isEqualToString:@"selector"])) continue;
        if ([key hasSuffix:@"Class"] || [key isEqualToString:@"class"]) {
            if (![value hasPrefix:@"YT"] && ![value hasPrefix:@"ML"]) continue;
        }
        safe[key]=[value copy];
    }
    return safe;
}
static NSString *QTDPath(NSUInteger index) {
    return [QTDDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"events-%lu.jsonl",(unsigned long)index]];
}
static NSArray<NSDictionary *> *QTDRead(NSUInteger index) {
    NSFileManager *fm=NSFileManager.defaultManager;
    if (![[fm attributesOfItemAtPath:QTDDirectory error:NULL][NSFileType] isEqualToString:NSFileTypeDirectory]) return @[];
    NSDictionary *attributes=[fm attributesOfItemAtPath:QTDPath(index) error:NULL];
    if (!attributes) return @[];
    if (![attributes[NSFileType] isEqualToString:NSFileTypeRegular] || [attributes[NSFileSize] unsignedLongLongValue]>QTDFileLimit) {
        [fm removeItemAtPath:QTDPath(index) error:NULL]; return @[];
    }
    NSData *data=[NSData dataWithContentsOfFile:QTDPath(index)];
    if (!data) { QTDFailures++; return nil; }
    NSString *text=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableArray *rows=[NSMutableArray array];
    NSTimeInterval now=NSDate.date.timeIntervalSince1970;
    for (NSString *line in [text componentsSeparatedByString:@"\n"]) {
        if (!line.length || line.length>4096) continue;
        id value=[NSJSONSerialization JSONObjectWithData:[line dataUsingEncoding:NSUTF8StringEncoding] options:0 error:NULL];
        if (![value isKindOfClass:NSDictionary.class]) continue;
        id time=value[@"at"], kind=value[@"event"];
        if (![time isKindOfClass:NSNumber.class] || !QTDPRecent([time doubleValue],now)) continue;
        if (![kind isKindOfClass:NSNumber.class] || [kind unsignedIntegerValue]>=QTDECount) continue;
        [rows addObject:@{@"at":time,@"event":@([kind unsignedIntegerValue]),@"fields":QTDSanitize(value[@"fields"])}];
    }
    return rows;
}
static NSData *QTDEncode(NSDictionary *row) {
    NSData *data=[NSJSONSerialization dataWithJSONObject:row options:NSJSONWritingSortedKeys error:NULL];
    if (!data || data.length>4095) return nil;
    NSMutableData *line=[data mutableCopy]; [line appendBytes:"\n" length:1]; return line;
}
static void QTDProtect(NSString *path) {
    NSMutableDictionary *attributes=[@{NSFilePosixPermissions:@0600} mutableCopy];
#if TARGET_OS_IPHONE
    attributes[NSFileProtectionKey]=NSFileProtectionCompleteUntilFirstUserAuthentication;
#endif
    if (![NSFileManager.defaultManager setAttributes:attributes ofItemAtPath:path error:NULL]) QTDFailures++;
}
static void QTDPrune(void) {
    NSFileManager *fm=NSFileManager.defaultManager;
    if (!QTDDirectory || ![[fm attributesOfItemAtPath:QTDDirectory error:NULL][NSFileType] isEqualToString:NSFileTypeDirectory]) return;
    for (NSUInteger i=0;i<3;i++) {
        NSString *path=QTDPath(i);
        if (![fm fileExistsAtPath:path]) continue;
        NSArray *rows=QTDRead(i);
        if (!rows) continue;
        NSMutableData *valid=[NSMutableData data];
        for (NSDictionary *row in rows) { NSData *line=QTDEncode(row); if (line && QTDPFits(valid.length,line.length)) [valid appendData:line]; }
        if (!valid.length) [fm removeItemAtPath:path error:NULL];
        else { if (![valid writeToFile:path options:NSDataWritingAtomic error:NULL]) QTDFailures++; QTDProtect(path); }
    }
}
static BOOL QTDEnsureDirectory(void) {
    if (!QTDDirectory) return NO;
    NSFileManager *fm=NSFileManager.defaultManager;
    NSDictionary *attributes=[fm attributesOfItemAtPath:QTDDirectory error:NULL];
    if (attributes) {
        if (![attributes[NSFileType] isEqualToString:NSFileTypeDirectory]) { QTDFailures++; return NO; }
        return YES;
    }
    if (![fm createDirectoryAtPath:QTDDirectory withIntermediateDirectories:YES attributes:@{NSFilePosixPermissions:@0700} error:NULL]) { QTDFailures++; return NO; }
    [[NSURL fileURLWithPath:QTDDirectory isDirectory:YES] setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:NULL];
    return YES;
}
static void QTDWrite(NSDictionary *row) {
    if (!QTDEnsureDirectory()) return;
    NSTimeInterval now=NSProcessInfo.processInfo.systemUptime;
    if (now-QTDLastPrune>=60) { QTDPrune(); QTDLastPrune=now; }
    NSData *line=QTDEncode(row); if (!line) return;
    NSFileManager *fm=NSFileManager.defaultManager;
    NSString *path=QTDPath(0);
    NSDictionary *attributes=[fm attributesOfItemAtPath:path error:NULL];
    if (attributes && (![attributes[NSFileType] isEqualToString:NSFileTypeRegular] || !QTDPFits([attributes[NSFileSize] unsignedLongLongValue],line.length))) {
        [fm removeItemAtPath:QTDPath(2) error:NULL];
        if ([fm fileExistsAtPath:QTDPath(1)]) [fm moveItemAtPath:QTDPath(1) toPath:QTDPath(2) error:NULL];
        if (![fm moveItemAtPath:path toPath:QTDPath(1) error:NULL]) { QTDFailures++; return; }
    }
    if (![fm fileExistsAtPath:path] && ![fm createFileAtPath:path contents:nil attributes:@{NSFilePosixPermissions:@0600}]) { QTDFailures++; return; }
    QTDProtect(path);
    NSFileHandle *file=[NSFileHandle fileHandleForWritingAtPath:path];
    if (!file) { QTDFailures++; return; }
    @try {
        if (![file seekToEndReturningOffset:NULL error:NULL] || ![file writeData:line error:NULL]) QTDFailures++;
    } @finally { if (![file closeAndReturnError:NULL]) QTDFailures++; }
}
static NSDictionary *QTDRow(QTDiagnosticEvent event, NSDictionary *fields) {
    return @{@"at":@(NSDate.date.timeIntervalSince1970),@"event":@(event),@"fields":QTDSanitize(fields)};
}
void QTDConfigure(NSString *directory) {
    QTDPrepare();
    @synchronized(QTDLock) {
        if (QTDConfigured) return;
        QTDConfigured=YES;
        dispatch_async(QTDQueue, ^{
            @try {
                QTDDirectory=[directory copy];
                if (!QTDEnsureDirectory()) return;
                NSURL *url=[NSURL fileURLWithPath:QTDDirectory isDirectory:YES];
                [url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:NULL];
                QTDPrune();
                // Auto-start if the user left the master toggle on (persistent daily logger).
                if ([[NSUserDefaults standardUserDefaults] boolForKey:QTEnhancedKey]) {
                    @synchronized(QTDLock) {
                        if (!QTDRecording && QTDPending < QTDPQueueLimit) {
                            QTDRecording=YES; QTDRateCount=0; QTDSamples=0; QTDPending++;
                            dispatch_async(QTDQueue, ^{ @try { QTDPrune(); QTDWrite(QTDRow(QTDEStart,@{})); } @catch (__unused NSException *e) { QTDFailures++; } @finally { @synchronized(QTDLock) { QTDPending--; } } });
                        }
                    }
                }
            } @catch (__unused NSException *e) { QTDFailures++; }
        });
    }
}
BOOL QTDEnabled(void) { QTDPrepare(); @synchronized(QTDLock) { return QTDRecording; } }
BOOL QTEnhancedEnabled(void) { return [[NSUserDefaults standardUserDefaults] boolForKey:QTEnhancedKey]; }
BOOL QTDStart(void) {
    QTDPrepare();
    @synchronized(QTDLock) {
        if (!QTDConfigured) return NO;
        if (QTDRecording) return YES;
        if (QTDPending>=QTDPQueueLimit) return NO;
        QTDRecording=YES; QTDRateCount=0; QTDSamples=0; QTDPending++;
        dispatch_async(QTDQueue, ^{ @try { QTDPrune(); QTDWrite(QTDRow(QTDEStart,@{})); } @catch (__unused NSException *e) { QTDFailures++; } @finally { @synchronized(QTDLock) { QTDPending--; } } });
    }
    return YES;
}
BOOL QTEnhancedStart(void) {
    [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:QTEnhancedKey];
    if (QTDStart()) return YES;
    [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:QTEnhancedKey];
    return NO;
}
void QTDStop(void) {
    QTDPrepare();
    @synchronized(QTDLock) {
        if (!QTDRecording) return;
        QTDRecording=NO;
        if (QTDPending>=QTDPQueueLimit) { QTDQueueDrops++; return; }
        QTDPending++;
        dispatch_async(QTDQueue, ^{ @try { QTDWrite(QTDRow(QTDEStop,@{})); } @catch (__unused NSException *e) { QTDFailures++; } @finally { @synchronized(QTDLock) { QTDPending--; } } });
    }
}
void QTEnhancedStop(void) {
    [[NSUserDefaults standardUserDefaults] setObject:@(NO) forKey:QTEnhancedKey];
    QTDStop();
}
BOOL QTDSample(void) {
    QTDPrepare();
    @synchronized(QTDLock) {
        if (!QTDRecording) return NO;
        NSTimeInterval now=NSProcessInfo.processInfo.systemUptime;
        if (now-QTDSampleWindow>=1) { QTDSampleWindow=now; QTDSamples=0; }
        if (QTDSamples>=4) return NO;
        QTDSamples++; return YES;
    }
}
void QTDEvent(QTDiagnosticEvent event, NSDictionary *fields) {
    QTDPrepare();
    @try {
        @synchronized(QTDLock) {
            if (!QTDRecording || event>=QTDECount) return;
            NSTimeInterval now=NSProcessInfo.processInfo.systemUptime;
            if (now-QTDRateWindow>=1) { QTDRateWindow=now; QTDRateCount=0; }
            BOOL critical=event==QTDEPlaybackError || (event==QTDEPlayer && [fields[@"phase"] isKindOfClass:NSNumber.class] && [fields[@"phase"] integerValue]==2);
            if (!QTDPAdmission(QTDPending,0,critical)) { QTDQueueDrops++; return; }
            if (!QTDPAdmission(0,QTDRateCount,critical)) { QTDRateDrops++; return; }
            NSDictionary *row=QTDRow(event,fields);
            QTDRateCount++; QTDPending++;
            dispatch_async(QTDQueue, ^{
                @try { QTDWrite(row); } @catch (__unused NSException *e) { QTDFailures++; }
                @finally { @synchronized(QTDLock) { QTDPending--; } }
            });
        }
    } @catch (__unused NSException *e) { }
}
void QTDError(NSError *error) {
    if (!QTDEnabled()) return;
    @try {
        NSError *current=error;
        for (NSUInteger depth=0;depth<3 && [current isKindOfClass:NSError.class];depth++) {
            NSUInteger domain=0;
            if ([current.domain isEqualToString:@"com.google.ios.youtube.ErrorDomain.playback"]) domain=1;
            else if ([current.domain isEqualToString:NSURLErrorDomain]) domain=2;
            else if ([current.domain isEqualToString:NSCocoaErrorDomain]) domain=3;
            else if ([current.domain isEqualToString:NSOSStatusErrorDomain]) domain=4;
            QTDEvent(QTDEPlaybackError,@{@"code":@(current.code),@"domain":@(domain),@"depth":@(depth)});
            id next=current.userInfo[NSUnderlyingErrorKey]; if (next==current) break; current=next;
        }
    } @catch (__unused NSException *e) { }
}
void QTDExport(void (^completion)(NSString *)) {
    QTDPrepare();
    @synchronized(QTDLock) {
        NSUInteger queueDrops=QTDQueueDrops, rateDrops=QTDRateDrops; BOOL enabled=QTDRecording; BOOL master=QTEnhancedEnabled();
        dispatch_async(QTDQueue, ^{
            NSMutableString *report=[NSMutableString stringWithFormat:@"QuietTube 1.2.0 enhanced diagnostics\nRecording: %@ (master %@). Queue drops: %lu. Rate drops: %lu.\nLocal only; review identifiers before sharing. Not all events are observed.\nEvents: 0=start,1=stop,2=app,3=playback error,4=player,5=mutation,6=feed boundary,7=element,8=hook.\nError domains: 0=other,1=YouTube,2=URL,3=Cocoa,4=OSStatus.\nApp phase: 0=active,1=background,2=memory warning,3=termination notification (not guaranteed).\nPlayer phase: 0=factory invoked,1=no-op supplied,2=session safety pause,3=native fallback.\nMutation slots follow existing report: collapse-start/end,layout,apply,insert-section,insert-content,replace-section/content,insert-notification.\nFeed phase: 0=presentation input,1=pre-insert,2=insert returned. Element mask is a heuristic, not ad proof; ad=-1 means marker unreadable.\nEnhanced logger: single master toggle, 3 files x 256 KiB, 7-day window. Auto-rotates, no upload.\n",enabled?@"yes":@"no",master?@"on":@"off",(unsigned long)queueDrops,(unsigned long)rateDrops];
            @try {
                if (QTDDirectory) {
                    QTDPrune();
                    for (NSInteger i=2;i>=0;i--) for (NSDictionary *row in QTDRead((NSUInteger)i)) {
                        NSData *line=QTDEncode(row); if (line) [report appendString:[[NSString alloc] initWithData:line encoding:NSUTF8StringEncoding]];
                    }
                }
            } @catch (__unused NSException *e) { QTDFailures++; }
            [report appendFormat:@"\nStorage failures: %lu. Pending or abrupt-exit events may be missing.\n",(unsigned long)QTDFailures];
            completion(report);
        });
    }
}
void QTDClear(void (^completion)(void)) {
    QTDPrepare();
    @synchronized(QTDLock) {
        // Keep the persistent master as-is; only stop transient admission before deletion.
        // The UI's Clear button does not turn off the master — toggle does.
        BOOL wasRecording=QTDRecording;
        QTDRecording=NO;
        dispatch_async(QTDQueue, ^{
            @try { if (QTDDirectory && QTDEnsureDirectory()) for (NSUInteger i=0;i<3;i++) {
                NSString *path=QTDPath(i);
                if ([NSFileManager.defaultManager fileExistsAtPath:path] && ![NSFileManager.defaultManager removeItemAtPath:path error:NULL]) QTDFailures++;
            } }
            @catch (__unused NSException *e) { QTDFailures++; }
            @synchronized(QTDLock) {
                // If master is still on, resume recording after the files are gone.
                if (wasRecording && QTEnhancedEnabled() && !QTDRecording && QTDPending < QTDPQueueLimit) {
                    QTDRecording=YES; QTDRateCount=0; QTDSamples=0; QTDPending++;
                    dispatch_async(QTDQueue, ^{ @try { QTDWrite(QTDRow(QTDEStart,@{})); } @catch (__unused NSException *e) { QTDFailures++; } @finally { @synchronized(QTDLock) { QTDPending--; } } });
                }
            }
            completion();
        });
    }
}
