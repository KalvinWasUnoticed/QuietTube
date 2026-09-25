#import "QTCore.h"
#import "QTPreferences.h"
#include <string.h>
#include "QTTemplateScan.h"

static NSString *const QTPrefix = @"QuietTube.v1.";
static NSMutableDictionary *QTStatuses;
static NSMutableDictionary *QTCounters;
static NSMutableSet *QTInstalled;
static NSDictionary *QTActiveFlags;
static NSMutableArray<NSString *> *QTElementGroups;
static NSMutableDictionary<NSString *,NSNumber *> *QTElementGroupCounts;
static NSUInteger QTElementsInspected;
static NSUInteger QTElementsWithoutNames;
static NSUInteger QTGroupsDropped;

NSArray<NSDictionary *> *QTOptions(void) {
    static NSArray *options;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        options = @[
          @{ @"key":@"mutationTrace", @"title":@"Trace minimize and feed updates", @"group":@"Advanced", @"default":@NO,
             @"note":@"Read-only bounded event timeline. Prepare ad test enables this. Restart required." },
// BEGIN 0.13 AD PROFILE
          @{ @"key":@"adTest", @"title":@"Ad test profile", @"group":@"Playback", @"default":@YES,
             @"note":@"Native player no-op plus scoped feed insertion filtering (requires feed ads). Experimental; restart required. Stops on observed playback errors." },
// END 0.13 AD PROFILE
// BEGIN 0.9.1 WATCH AGAIN
          @{ @"key":@"watchAgain", @"title":@"Hide “Watch it again” shelves", @"group":@"Distractions", @"default":@NO,
             @"note":@"English shelf-title matching, including an experimental horizontal-element fallback. Requires Extended feed formats. Does not delete watch history." },
// END 0.9.1 WATCH AGAIN
          @{ @"key":@"mixes", @"title":@"Hide Mix recommendations", @"group":@"Distractions", @"default":@NO,
             @"note":@"Mix/radio renderer and RD playlist destination matching. Requires Extended feed formats. Nested Mix links may also match; does not use video titles." },
          @{ @"key":@"displayAds", @"title":@"Additional display-ad formats", @"group":@"Distractions", @"default":@NO,
             @"note":@"Experimental image/display-ad template families. Requires Extended feed formats and Feed ads. May match nested promotional content." },
          @{ @"key":@"topicsShelves", @"title":@"Hide “Explore more topics” shelves", @"group":@"Distractions", @"default":@NO,
             @"note":@"Experimental chips-shelf / exact shelf-title matching. Requires Extended feed formats; other chips shelves may also match." },
          @{ @"key":@"edgeCards", @"title":@"Hide edge-to-edge video cards", @"group":@"Distractions", @"default":@NO,
             @"note":@"Experimental inline/portrait video-card heuristic; not exact geometry detection. May also hide compact portrait cards. Requires Extended feed formats." },
          @{ @"key":@"plainLogo", @"title":@"Use plain YouTube logo", @"group":@"Distractions", @"default":@YES,
             @"note":@"Replaces event header images at logo-specific hooks. Restart required; verify logo hook status in diagnostics." },
          @{ @"key":@"inspectElements", @"title":@"Inspect unmatched templates", @"group":@"Advanced", @"default":@NO,
             @"note":@"Opt-in capture of identifier-shaped names, including extensionless formats; not raw payloads. Requires Extended feed formats and restart. Review before sharing." },
          @{ @"key":@"extendedFeed", @"title":@"Extended feed formats", @"group":@"Distractions", @"default":@NO,
             @"note":@"Experimental element-template matching and deeper traversal. Off restores the earlier filter." },
          @{ @"key":@"playables", @"title":@"Hide Playables shelves", @"group":@"Distractions", @"default":@NO,
             @"note":@"Requires Extended feed formats. Limited template coverage." },
          @{ @"key":@"eventPromos", @"title":@"Hide featured / promo cards", @"group":@"Distractions", @"default":@NO,
             @"note":@"Requires Extended feed formats. Experimental; does not change the header logo." },
          @{ @"key":@"feedAds", @"title":@"Filter explicit feed ads", @"group":@"Distractions", @"default":@YES,
             @"note":@"Filter recognized feed ads. Dynamic insertion filtering also requires video-ad protection." },
          @{ @"key":@"shorts", @"title":@"Filter explicit Shorts shelves", @"group":@"Distractions", @"default":@NO,
             @"note":@"Does not hide the Shorts tab or every Shorts surface." },
          @{ @"key":@"background", @"title":@"Background audio", @"group":@"Playback", @"default":@NO },
          @{ @"key":@"autoplay", @"title":@"Stop automatic next video", @"group":@"Playback", @"default":@NO,
             @"note":@"Stops selected next-video actions, not in-feed video previews." },
        ];
    });
    return options;
}

void QTRegisterDefaults(void) {
    NSUserDefaults *d = NSUserDefaults.standardUserDefaults;
    QTInitializePreferences(d, QTOptions());
    NSMutableDictionary *active = [NSMutableDictionary dictionary];
    active[@"enabled"] = @([d boolForKey:[QTPrefix stringByAppendingString:@"enabled"]]);
    for (NSDictionary *o in QTOptions())
        active[o[@"key"]] = @(![o[@"disabled"] boolValue] && [d boolForKey:[QTPrefix stringByAppendingString:o[@"key"]]]);
    QTActiveFlags = [active copy]; // immutable until next process launch
    QTStatuses = [NSMutableDictionary dictionary];
    QTCounters = [NSMutableDictionary dictionary];
    QTInstalled = [NSMutableSet set];
    QTElementGroups = [NSMutableArray array];
    QTElementGroupCounts = [NSMutableDictionary dictionary];
}
BOOL QTOn(NSString *key) {
    return [QTActiveFlags[@"enabled"] boolValue] && [QTActiveFlags[key] boolValue];
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
void QTResetElementCapture(void) {
    @synchronized(QTElementGroups) {
        [QTElementGroups removeAllObjects];
        [QTElementGroupCounts removeAllObjects];
        QTElementsInspected=0;
        QTElementsWithoutNames=0;
        QTGroupsDropped=0;
    }
}
void QTObserveUnmatchedElement(NSData *data) {
    if (!QTOn(@"inspectElements") || ![data isKindOfClass:NSData.class] || data.length>262144) return;
    @synchronized(QTElementGroups) {
        if (QTElementsInspected>=128) return;
        QTElementsInspected++;
        char tokens[8][97]={{0}};
        size_t count=QTExtractTemplateNames(data.bytes,data.length,tokens,8);
        if (!count) { QTElementsWithoutNames++; return; }
        NSMutableArray<NSString *> *names=[NSMutableArray array];
        for (size_t i=0;i<count;i++) [names addObject:[NSString stringWithUTF8String:tokens[i]]];
        [names sortUsingSelector:@selector(compare:)];
        NSString *group=[names componentsJoinedByString:@", "];
        if (!QTElementGroupCounts[group]) {
            if (QTElementGroups.count>=48) { QTGroupsDropped++; return; }
            [QTElementGroups addObject:group];
        }
        QTElementGroupCounts[group]=@([QTElementGroupCounts[group] unsignedIntegerValue]+1);
    }
}
NSString *QTDiagnostics(void) {
    NSMutableString *s = [NSMutableString stringWithFormat:
        @"QuietTube 1.0.1 Ad profile and bounded troubleshooting\nYouTube %@\niOS %@\n\nInstalled does NOT mean device-tested. Unavailable hooks are not active.\n\n",
        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], UIDevice.currentDevice.systemVersion];
// BEGIN 0.13 AD PROFILE
    [s appendString:QTAdReport()];
// END 0.13 AD PROFILE
    [s appendString:@"ACTIVE THIS LAUNCH\n"];
    for (NSString *key in [[QTActiveFlags allKeys] sortedArrayUsingSelector:@selector(compare:)])
        [s appendFormat:@"%@ = %@\n", key, [QTActiveFlags[key] boolValue] ? @"on" : @"off"];
    [s appendString:@"\nFLAGS SAVED FOR NEXT LAUNCH\n"];
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
    [s appendString:@"\nUNMATCHED ELEMENT TEMPLATE CAPTURE\n"];
    [s appendFormat:@"capture enabled this launch: %@\n", QTOn(@"inspectElements") ? @"yes" : @"no"];
    [s appendString:@"Lexical identifier-shaped names, not verified root renderers. Nested names may appear. Groups are NOT individual visible cards. Review before sharing.\n"];
    @synchronized(QTElementGroups) {
        [s appendFormat:@"unmatched elements sampled: %lu / 128\nelements without accepted identifiers: %lu\ngroup-cap drops: %lu\n",
          (unsigned long)QTElementsInspected,(unsigned long)QTElementsWithoutNames,(unsigned long)QTGroupsDropped];
        NSUInteger index=1;
        for (NSString *group in QTElementGroups)
            [s appendFormat:@"group %lu (seen %@): %@\n",(unsigned long)index++,QTElementGroupCounts[group],group];
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

// UI-only comparison: use the raw launch snapshot, not effective QTOn values.
BOOL QTSettingsPendingRestart(void) {
    for (NSString *key in QTActiveFlags) {
        if ([QTActiveFlags[key] boolValue] != [NSUserDefaults.standardUserDefaults boolForKey:[QTPrefix stringByAppendingString:key]]) return YES;
    }
    return NO;
}
