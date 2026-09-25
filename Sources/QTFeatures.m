#import "QTCore.h"
#import "QTDiagnosticLog.h"
#import "QTDiagnosticsBridge.h"
#include "QTFeedRules.h"

static _Thread_local NSUInteger QTNodeBudget;
static NSUInteger QTDepthLimit(void) { return QTOn(@"extendedFeed") ? 14 : 6; }

// 0.2: no protobuf repeated-field getter overrides, no layoutSubviews hooks,
// no view hiding, no playback response mutation. Filter at a presentation boundary.
static NSString *QTShelfTitle(id node) {
    // Only shelf headers, never arbitrary video-title fields.
    NSString *name = NSStringFromClass([node class]);
    if (![name hasPrefix:@"YTI"] || ![name hasSuffix:@"ShelfRenderer"]) return nil;
    id title = QTGet(node,@"title");
    id simple = QTGet(title,@"simpleText");
    if ([simple isKindOfClass:NSString.class]) return simple;
    id runs = QTGet(title,@"runsArray");
    if (![runs isKindOfClass:NSArray.class] || [runs count] > 12) return nil;
    NSMutableString *joined = [NSMutableString string];
    for (id run in runs) {
        id text = QTGet(run,@"text");
        if (![text isKindOfClass:NSString.class] || [text length] > 100) return nil;
        [joined appendString:text];
    }
    return joined;
}
static BOOL QTDropNode(id node) {
    if (QTOn(@"feedAds")) {
        for (NSString *selector in @[@"hasPromotedVideoRenderer", @"hasCompactPromotedVideoRenderer",
            @"hasPromotedVideoInlineMutedRenderer", @"hasDisplayAdRenderer", @"hasAdSlotRenderer"])
            if (QTBool(node,selector)) { QTCount(@"match explicit ad field"); return YES; }
        if (QTBool(QTGet(node,@"compatibilityOptions"),@"hasAdLoggingData")) { QTCount(@"match explicit ad logging"); return YES; }
    }
    if (QTOn(@"shorts") && (QTBool(node,@"hasReelShelfRenderer") || QTBool(node,@"hasReelItemRenderer")))
        { QTCount(@"match explicit Shorts field"); return YES; }
    if (!QTOn(@"extendedFeed")) return NO;
    if (QTOn(@"mixes")) {
        // Only the item's navigation watch endpoint, not arbitrary nested menus,
        // descriptions, every playlist, or titles. All getters signature-checked.
        id endpoint = QTGet(QTGet(node,@"navigationEndpoint"),@"watchEndpoint");
        id playlistID = QTGet(endpoint,@"playlistId");
        if ([playlistID isKindOfClass:NSString.class] && [playlistID length]<=96) {
            NSData *identifier = [playlistID dataUsingEncoding:NSUTF8StringEncoding];
            if (QTIsRadioPlaylistID(identifier.bytes,identifier.length)) {
                QTCount(@"match Mix navigation playlist ID"); return YES;
            }
        }
        for (NSString *selector in @[@"hasAutomixPreviewVideoRenderer", @"hasAutomixPlaylistVideoRenderer",
                                    @"hasRadioRenderer", @"hasPivotRadioRenderer"])
            if (QTBool(node,selector)) { QTCount(@"match explicit Mix renderer field"); return YES; }
        if ([@[@"YTIAutomixPreviewVideoRenderer", @"YTIAutomixPlaylistVideoRenderer",
                @"YTIRadioRenderer", @"YTIPivotRadioRenderer"] containsObject:NSStringFromClass([node class])]) {
            QTCount(@"match explicit Mix renderer class"); return YES;
        }
    }
// BEGIN 0.9.1 WATCH AGAIN
    if (QTOn(@"watchAgain")) {
        NSString *title = [[QTShelfTitle(node) stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] lowercaseString];
        if ([title isEqualToString:@"watch it again"] || [title isEqualToString:@"watch again"]) {
            QTCount(@"match Watch again shelf title"); return YES;
        }
    }
// END 0.9.1 WATCH AGAIN
    if (QTOn(@"topicsShelves")) {
        NSString *title = [[QTShelfTitle(node) stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet] lowercaseString];
        if ([title isEqualToString:@"explore more topics"]) {
            QTCount(@"match Explore topics shelf title"); return YES;
        }
    }
    NSString *className = NSStringFromClass([node class]);
    if (QTOn(@"playables") && [@[@"YTIPlayablesShelfRenderer", @"YTIPlayableItemRenderer",
        @"YTICompactBoxGameRenderer", @"YTIPlayableGameRenderer"] containsObject:className]) {
        QTCount(@"match Playables renderer class"); return YES;
    }
    // Only read element payloads at this presentation boundary. Never serialize
    // whole sections or replace elementData/model getters.
    if (![className hasPrefix:@"YTI"] || ![className hasSuffix:@"ElementRenderer"]) return NO;
    QTCount(@"element renderer visited");
    id data = QTGet(node,@"elementData");
    if (![data isKindOfClass:NSData.class] || [data length] == 0) {
        QTCount(@"element payload missing or unreadable"); return NO;
    }
    if ([data length] > 262144) { QTCount(@"oversize element payload skipped"); return NO; }
    QTCount(@"element payload inspected");
    unsigned kind = QTClassifyElementBytes([data bytes],[data length]);
    if ((kind & QTFeedShorts) && QTOn(@"shorts")) { QTCount(@"match Shorts element tokens"); return YES; }
    if ((kind & QTFeedAd) && QTOn(@"feedAds")) { QTCount(@"match ad element tokens"); return YES; }
    if ((kind & QTFeedPlayable) && QTOn(@"playables")) { QTCount(@"match Playables element tokens"); return YES; }
    if ((kind & QTFeedPromo) && QTOn(@"eventPromos")) { QTCount(@"match promo element tokens"); return YES; }
    if ((kind & QTFeedTopics) && QTOn(@"topicsShelves")) { QTCount(@"match topics shelf element tokens"); return YES; }
    if ((kind & QTFeedEdgeVideo) && QTOn(@"edgeCards")) { QTCount(@"match inline portrait card heuristic"); return YES; }
    if ((kind & QTFeedDisplayAd) && QTOn(@"feedAds") && QTOn(@"displayAds")) {
        QTCount(@"match additional display-ad format"); return YES;
    }
    if ((kind & QTFeedInlineShort) && QTOn(@"edgeCards")) {
        QTCount(@"match inline overlay plus Shorts icon"); return YES;
    }
    if ((kind & QTFeedMixURL) && QTOn(@"mixes")) {
        QTCount(@"match Mix RD playlist query"); return YES;
    }
    if ((kind & QTFeedMix) && QTOn(@"mixes")) {
        QTCount(@"match Mix element tokens"); return YES;
    }
// BEGIN 0.9.1 WATCH AGAIN
    if ((kind & QTFeedWatchAgain) && QTOn(@"watchAgain")) {
        QTCount(@"match Watch again horizontal shelf candidate"); return YES;
    }
// END 0.9.1 WATCH AGAIN
    QTObserveUnmatchedElement(data); // observation only; never changes the filtering decision
    QTCount(@"element retained — no active rule matched");
    return NO;
}
static id QTFilteredNode(id node, NSUInteger depth);
static NSArray *QTFilteredArray(NSArray *original, NSUInteger depth) {
    if (![original isKindOfClass:NSArray.class] || depth > QTDepthLimit()) return original;
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:original.count];
    BOOL changed = NO;
    for (id item in original) {
        id filtered = QTFilteredNode(item,depth+1);
        if (filtered != item) changed = YES;
        if (filtered) [result addObject:filtered];
    }
    // Preserve original identity and mutability unless a real edit is required.
    return changed ? result : original;
}
static id QTFilteredNode(id node, NSUInteger depth) {
    if (!node) return node;
    if (depth > QTDepthLimit()) { if (QTOn(@"extendedFeed")) QTCount(@"traversal depth limit"); return node; }
    if (QTOn(@"extendedFeed")) {
        if (!QTNodeBudget) { QTCount(@"traversal node budget exhausted"); return node; }
        QTNodeBudget--;
        QTCount(@"extended traversal node visited");
    }
    if (QTDropNode(node)) { QTCount(@"presentation nodes filtered"); return nil; }
    // A closed list of renderer edges. No whole-model descriptions or general KVC.
    NSArray *arrays = @[@"contentsArray",@"itemsArray"];
    NSArray *edges = @[@"itemSectionRenderer",@"elementRenderer",@"shelfRenderer",@"content",
                       @"horizontalListRenderer",@"richItemRenderer"];
    if (QTOn(@"extendedFeed")) edges = [edges arrayByAddingObjectsFromArray:
        @[@"richSectionRenderer",@"richGridRenderer",@"verticalListRenderer",@"sectionListRenderer"]];
    id output = node;
    for (NSString *key in [arrays arrayByAddingObjectsFromArray:edges]) {
        BOOL isArray = [arrays containsObject:key];
        NSString *cap = [[[key substringToIndex:1] uppercaseString] stringByAppendingString:[key substringFromIndex:1]];
        SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@:",cap]);
        if (!QTMatches(node,setter,@"v@")) continue;
        SEL has = NSSelectorFromString([@"has" stringByAppendingString:cap]);
        if (!isArray && QTMatches(node,has,@"B") && !QTBool(node,NSStringFromSelector(has))) continue;
        id original = QTGet(node,key);
        if (!original || original == node) continue;
        if (isArray && ![original isKindOfClass:NSArray.class]) continue;
        id filtered = isArray ? QTFilteredArray(original,depth+1) : QTFilteredNode(original,depth+1);
        if (filtered == original) continue;
        // Don't leave an empty content wrapper after deleting its only child.
        if (!filtered || (isArray && [original count] > 0 && [filtered count] == 0)) return nil;
        if (output == node) {
            if (![node conformsToProtocol:@protocol(NSCopying)]) return node;
            output = [node copy];
            if (!output || output == node) return node;
        }
        ((void (*)(id,SEL,id))objc_msgSend)(output,setter,filtered);
    }
    return output;
}
static void QTNoArgAction(NSString *cls, NSString *method, NSString *flag) {
    if (!QTOn(flag)) return;
    QTHook(cls,method,@"v",^id(IMP old,SEL sel) {
        return ^(id object) { QTCount(flag); };
    });
}
void QTInstallFeatures(void) {
    // When the master switch is off, not even diagnostic feature hooks are installed.
    if (!QTOn(@"enabled")) return;
    QTInstallPlainLogo();
// BEGIN 0.13 AD PROFILE
    QTInstallAdProfile();
    QTInstallMutationTrace();
// END 0.13 AD PROFILE
    if (QTDEnabled() || QTOn(@"feedAds") || QTOn(@"shorts") || (QTOn(@"extendedFeed") && (QTOn(@"playables") || QTOn(@"eventPromos") || QTOn(@"topicsShelves") || QTOn(@"edgeCards") || QTOn(@"inspectElements") || QTOn(@"mixes") || QTOn(@"watchAgain")))) {
        QTHook(@"YTInnerTubeCollectionViewController",@"addSectionsFromArray:",@"v@",^id(IMP old,SEL sel) {
            return ^(id object,NSArray *sections) {
                QTDDiagnosticBoundary(object,sections,0);
                NSArray *filtered = sections;
                QTCount(@"presentation boundary invoked");
                if ([sections isKindOfClass:NSArray.class]) {
                    @try {
                        QTNodeBudget = 1200;
                        filtered = QTFilteredArray(sections,0);
                        if (filtered != sections) QTCount(@"presentation batch changed");
                        // The crash report shows a downstream index-zero assumption.
                        // Never turn a nonempty top-level presentation batch empty.
                        // Prefer showing ads to sending a fabricated empty batch.
                        if (sections.count > 0 && filtered.count == 0) {
                            QTCount(@"empty presentation batch prevented — kept original");
                            filtered = sections;
                        }
                    }
                    @catch (__unused NSException *error) {
                        QTCount(@"presentation filter exception — kept original");
                        filtered = sections;
                    }
                }
                ((void (*)(id,SEL,id))old)(object,sel,filtered);
            };
        });
    }
    if (QTOn(@"background")) {
        QTBoolHook(@"YTIPlayabilityStatus",@"isPlayableInBackground",@"background",YES);
        QTBoolHook(@"MLVideo",@"playableInBackground",@"background",YES);
    }
    QTNoArgAction(@"YTWatchFlowController",@"playAutoplay",@"autoplay");
    QTNoArgAction(@"YTQueueController",@"triggerPendingAutoplay",@"autoplay");
    // Error observation only; the native handler always executes, with no retries.
    QTHook(@"YTMainAppVideoPlayerOverlayViewController",@"handleError:",@"v@",^id(IMP old,SEL sel) {
        return ^(id object,NSError *error) {
            QTDError(error);
            if ([error isKindOfClass:NSError.class]) {
// BEGIN 0.13 AD PROFILE
                QTAdPlaybackError(error);
// END 0.13 AD PROFILE
                NSString *kind = [error.domain isEqualToString:@"com.google.ios.youtube.ErrorDomain.playback"] ? @"YouTube" : @"other";
                QTCount([NSString stringWithFormat:@"playback error %@ code %ld",kind,(long)error.code]);
            }
            ((void (*)(id,SEL,id))old)(object,sel,error);
        };
    });
}
