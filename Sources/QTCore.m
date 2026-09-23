#import "QTCore.h"
#include <string.h>

static NSString *const QTPrefix = @"QuietTube.v1.";
static NSMutableDictionary *QTStatuses;
static NSMutableDictionary *QTCounters;
static NSMutableSet *QTInstalled;

NSArray<NSDictionary *> *QTOptions(void) {
    static NSArray *options;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        // All switches control real hooks. Availability is reported separately.
        options = @[
          @{@"key":@"playerAds", @"title":@"Block player ads", @"group":@"Playback", @"default":@YES,
            @"note":@"Experimental response filtering. Not a verified detection bypass."},
          @{@"key":@"background", @"title":@"Background audio", @"group":@"Playback", @"default":@YES,
            @"note":@"Use YouTube’s native audio path; needs LiveContainer testing."},
          @{@"key":@"pip", @"title":@"Picture in Picture", @"group":@"Playback", @"default":@YES,
            @"note":@"Native PiP eligibility. Enable automatic PiP in iOS and YouTube."},
          @{@"key":@"autoplay", @"title":@"Stop automatic next video", @"group":@"Playback", @"default":@YES},
          @{@"key":@"previews", @"title":@"Stop feed previews", @"group":@"Playback", @"default":@YES,
            @"note":@"Candidate hooks; if unavailable, use YouTube’s Playback in feeds setting."},
          @{@"key":@"feedAds", @"title":@"Hide feed & companion ads", @"group":@"Distractions", @"default":@YES,
            @"note":@"Filters explicit promoted renderers; coverage may be incomplete."},
          @{@"key":@"promos", @"title":@"Hide promotional prompts", @"group":@"Distractions", @"default":@YES},
          @{@"key":@"shortsTab", @"title":@"Hide Shorts tab", @"group":@"Distractions", @"default":@YES},
          @{@"key":@"shorts", @"title":@"Hide Shorts shelves", @"group":@"Distractions", @"default":@YES},
          @{@"key":@"home", @"title":@"Hide Home recommendations", @"group":@"Distractions", @"default":@YES,
            @"note":@"Only hides content when the Home browse ID is identified."},
          @{@"key":@"related", @"title":@"Hide related videos", @"group":@"Distractions", @"default":@YES},
          @{@"key":@"endscreen", @"title":@"Hide end-screen suggestions", @"group":@"Distractions", @"default":@YES},
          @{@"key":@"comments", @"title":@"Hide comment previews", @"group":@"Distractions", @"default":@NO,
            @"note":@"Does not guarantee every comment entry point is hidden."},
          @{@"key":@"community", @"title":@"Hide community posts", @"group":@"Distractions", @"default":@YES},
          @{@"key":@"create", @"title":@"Hide Create tab", @"group":@"Distractions", @"default":@YES},
          @{@"key":@"bell", @"title":@"Hide notification bell", @"group":@"Distractions", @"default":@YES},
          @{@"key":@"cast", @"title":@"Hide Cast button", @"group":@"Distractions", @"default":@NO}
        ];
    });
    return options;
}

void QTRegisterDefaults(void) {
    NSMutableDictionary *defaults = [NSMutableDictionary dictionary];
    defaults[[QTPrefix stringByAppendingString:@"enabled"]] = @YES;
    for (NSDictionary *option in QTOptions())
        defaults[[QTPrefix stringByAppendingString:option[@"key"]]] = option[@"default"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
    QTStatuses = [NSMutableDictionary dictionary];
    QTCounters = [NSMutableDictionary dictionary];
    QTInstalled = [NSMutableSet set];
}
BOOL QTOn(NSString *key) {
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    return [d boolForKey:[QTPrefix stringByAppendingString:@"enabled"]] &&
           [d boolForKey:[QTPrefix stringByAppendingString:key]];
}
void QTSet(NSString *key, BOOL value) {
    [[NSUserDefaults standardUserDefaults] setBool:value forKey:[QTPrefix stringByAppendingString:key]];
}
void QTCount(NSString *event) {
    @synchronized(QTCounters) { QTCounters[event] = @([QTCounters[event] unsignedLongLongValue] + 1); }
}
static void QTStatus(NSString *key, NSString *value) {
    @synchronized(QTStatuses) { QTStatuses[key] = value; }
}
// Normalize only ABI-equivalent types. Never guess object versus scalar returns.
static char QTType(const char *t) {
    while (*t && strchr("rnNoORV", *t)) t++;
    if (*t == 'c' || *t == 'B') return 'B';
    if (*t == 'q' || *t == 'Q') return 'Q';
    return *t;
}
BOOL QTMatches(id object, SEL sel, NSString *expected) {
    if (!object || ![object respondsToSelector:sel]) return NO;
    NSMethodSignature *sig = [object methodSignatureForSelector:sel];
    if (!sig || sig.numberOfArguments != expected.length + 1) return NO;
    if (QTType(sig.methodReturnType) != [expected characterAtIndex:0]) return NO;
    for (NSUInteger i = 2; i < sig.numberOfArguments; i++)
        if (QTType([sig getArgumentTypeAtIndex:i]) != [expected characterAtIndex:i-1]) return NO;
    return YES;
}
id QTGet(id object, NSString *selector) {
    SEL sel = NSSelectorFromString(selector);
    if (!QTMatches(object, sel, @"@")) return nil;
    @try { return ((id (*)(id,SEL))objc_msgSend)(object, sel); }
    @catch (__unused NSException *e) { return nil; }
}
BOOL QTBool(id object, NSString *selector) {
    SEL sel = NSSelectorFromString(selector);
    if (!QTMatches(object, sel, @"B")) return NO;
    @try { return ((BOOL (*)(id,SEL))objc_msgSend)(object, sel); }
    @catch (__unused NSException *e) { return NO; }
}
void QTHook(NSString *name, NSString *selector, NSString *expected, id (^factory)(IMP, SEL)) {
    NSString *key = [NSString stringWithFormat:@"%@ / %@", name, selector];
    if ([QTInstalled containsObject:key]) return;
    Class cls = NSClassFromString(name);
    SEL sel = NSSelectorFromString(selector);
    Method method = cls ? class_getInstanceMethod(cls, sel) : NULL;
    if (!method) { QTStatus(key, @"unavailable"); return; }
    NSMethodSignature *sig = [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(method)];
    BOOL valid = sig.numberOfArguments == expected.length + 1 &&
                 QTType(sig.methodReturnType) == [expected characterAtIndex:0];
    for (NSUInteger i=2; valid && i<sig.numberOfArguments; i++)
        valid = QTType([sig getArgumentTypeAtIndex:i]) == [expected characterAtIndex:i-1];
    if (!valid) { QTStatus(key, @"signature mismatch — skipped"); return; }
    IMP old = method_getImplementation(method);
    IMP replacement = imp_implementationWithBlock(factory(old, sel));
    if (!replacement) { QTStatus(key, @"block creation failed"); return; }
    // Add an override if inherited: never patch a superclass by accident.
    if (!class_addMethod(cls, sel, replacement, method_getTypeEncoding(method)))
        method_setImplementation(class_getInstanceMethod(cls, sel), replacement);
    [QTInstalled addObject:key];
    QTStatus(key, @"installed (behavior unverified)");
}
void QTBoolHook(NSString *name, NSString *selector, NSString *key, BOOL value) {
    QTHook(name, selector, @"B", ^id(IMP old, SEL sel) {
        return ^BOOL(id object) {
            if (QTOn(key)) { QTCount(key); return value; }
            return ((BOOL (*)(id,SEL))old)(object,sel);
        };
    });
}
NSString *QTDiagnostics(void) {
    NSMutableString *s = [NSMutableString stringWithFormat:
        @"QuietTube 0.1 experimental\nYouTube %@\niOS %@\n\nInstalled does NOT mean device-tested. Unavailable hooks are not active.\n\n",
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], UIDevice.currentDevice.systemVersion];
    [s appendString:@"FLAGS (stored values)\n"];
    NSUserDefaults *d = NSUserDefaults.standardUserDefaults;
    [s appendFormat:@"enabled = %@\n", [d boolForKey:[QTPrefix stringByAppendingString:@"enabled"]] ? @"on" : @"off"];
    for (NSDictionary *o in QTOptions()) [s appendFormat:@"%@ = %@\n", o[@"key"],
        [d boolForKey:[QTPrefix stringByAppendingString:o[@"key"]]] ? @"on" : @"off"];
    [s appendString:@"\nHOOKS\n"];
    @synchronized(QTStatuses) {
        for (NSString *k in [[QTStatuses allKeys] sortedArrayUsingSelector:@selector(compare:)])
            [s appendFormat:@"%@ : %@\n", k, QTStatuses[k]];
    }
    [s appendString:@"\nSESSION COUNTERS (not unique ads/videos)\n"];
    @synchronized(QTCounters) {
        for (NSString *k in [[QTCounters allKeys] sortedArrayUsingSelector:@selector(compare:)])
            [s appendFormat:@"%@ : %@\n", k, QTCounters[k]];
    }
    return s;
}

__attribute__((constructor)) static void QTStart(void) {
    @autoreleasepool {
        if (![NSBundle.mainBundle.bundleIdentifier containsString:@"youtube"]) return;
        QTRegisterDefaults();
        // Bounded late-class retries, never scan/realize every Swift class.
        for (NSNumber *delay in @[@0,@1,@3,@8]) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay.doubleValue*NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                QTInstallSettings();
                if ([[NSBundle.mainBundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"] isEqualToString:@"21.38.2"])
                    QTInstallFeatures();
                else QTStatus(@"version gate", @"Only settings loaded: unsupported YouTube version");
            });
        }
    }
}
