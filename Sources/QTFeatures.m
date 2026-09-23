#import "QTCore.h"

static BOOL QTContains(NSString *text, NSArray<NSString *> *markers) {
    if (![text isKindOfClass:NSString.class]) return NO;
    for (NSString *m in markers) if ([text containsString:m]) return YES;
    return NO;
}
static id QTPath(id object, NSArray<NSString *> *path) {
    for (NSString *p in path) { object = QTGet(object,p); if (!object) break; }
    return object;
}
static NSString *QTIdentifier(id object, NSUInteger depth) {
    if (!object || depth > 3) return @"";
    for (NSString *s in @[@"pivotIdentifier",@"tabIdentifier",@"browseId",@"identifier"]) {
        id token = QTGet(object,s);
        if ([token isKindOfClass:NSString.class] && [token length]) return [token lowercaseString];
    }
    for (NSString *s in @[@"pivotBarItemRenderer",@"pivotBarIconOnlyItemRenderer",@"navigationEndpoint",@"browseEndpoint",@"endpoint",@"renderer"]) {
        id nested = QTGet(object,s);
        if (nested && nested != object) {
            NSString *token = QTIdentifier(nested,depth+1);
            if (token.length) return token;
        }
    }
    return @"";
}
static BOOL QTExplicitAd(id node) {
    for (NSString *s in @[@"hasPromotedVideoRenderer",@"hasCompactPromotedVideoRenderer",
        @"hasPromotedVideoInlineMutedRenderer",@"hasDisplayAdRenderer",@"hasAdSlotRenderer",
        @"hasCompanionAdRenderer",@"hasAppPromoCompanionAdRenderer",@"hasShoppingCompanionAdRenderer"])
        if (QTBool(node,s)) return YES;
    id options = QTGet(node,@"compatibilityOptions");
    return QTBool(options,@"hasAdLoggingData");
}
static BOOL QTReject(id node, NSUInteger depth) {
    if (!node || depth > 2) return NO;
    if (QTOn(@"feedAds") && QTExplicitAd(node)) { QTCount(@"explicit ads filtered"); return YES; }
    if (QTOn(@"shorts") && (QTBool(node,@"hasReelShelfRenderer") || QTBool(node,@"hasReelItemRenderer"))) {
        QTCount(@"shorts filtered"); return YES;
    }
    if (QTOn(@"community") && (QTBool(node,@"hasBackstagePostThreadRenderer") || QTBool(node,@"hasBackstagePostRenderer"))) return YES;
    // Only inspect individual element renderers, never stringify whole feed responses.
    if ([NSStringFromClass([node class]) isEqualToString:@"YTIElementRenderer"]) {
        NSString *text = [[node description] lowercaseString];
        if (QTOn(@"feedAds") && QTContains(text,@[@"feed_ad_metadata",@"text_search_ad",@"brand_promo",@"product_engagement_panel",@"product_carousel",@"shopping_carousel"])) return YES;
        if (QTOn(@"shorts") && QTContains(text,@[@"shorts_shelf",@"shorts_video_cell",@"reel_shelf"])) return YES;
        if (QTOn(@"community") && QTContains(text,@[@"backstage_post",@"post_shelf"])) return YES;
        if (QTOn(@"comments") && QTContains(text,@[@"comments_entry_point",@"comment_teaser",@"comments_header"])) return YES;
        if (QTOn(@"related") && QTContains(text,@[@"related_video",@"watch_next_feed"])) return YES;
    }
    for (NSString *s in @[@"elementRenderer",@"content",@"shelfRenderer"]) {
        id child = QTGet(node,s);
        if (child && child != node && QTReject(child,depth+1)) return YES;
    }
    return NO;
}
static _Thread_local unsigned QTFiltering;
static void QTFilterGetter(NSString *cls, NSString *getter) {
    QTHook(cls,getter,@"@",^id(IMP old,SEL sel) {
        return ^id(id object) {
            id raw = ((id (*)(id,SEL))old)(object,sel);
            if (![raw isKindOfClass:NSArray.class] || QTFiltering || !QTOn(@"enabled")) return raw;
            QTFiltering++;
            NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:[raw count]];
            @try {
                for (id node in raw) if (!QTReject(node,0)) [filtered addObject:node];
            } @catch (__unused NSException *e) {
                QTCount(@"filter exceptions — original retained");
                filtered = nil;
            } @finally { QTFiltering--; }
            return filtered ?: raw;
        };
    });
}
static void QTSuppressVoid(NSString *cls,NSString *method,NSString *flag,BOOL argument) {
    QTHook(cls,method,argument ? @"v@" : @"v",^id(IMP old,SEL sel) {
        if (argument) return ^(id obj,id arg) {
            if (QTOn(flag)) { QTCount(flag); return; }
            ((void (*)(id,SEL,id))old)(obj,sel,arg);
        };
        return ^(id obj) {
            if (QTOn(flag)) { QTCount(flag); return; }
            ((void (*)(id,SEL))old)(obj,sel);
        };
    });
}
static const void *QTHiddenBefore = &QTHiddenBefore;
static void QTHide(UIView *view,BOOL hide) {
    if (![view isKindOfClass:UIView.class]) return;
    NSNumber *previous = objc_getAssociatedObject(view,QTHiddenBefore);
    if (hide) {
        if (!previous) objc_setAssociatedObject(view,QTHiddenBefore,@(view.hidden),OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        view.hidden = YES;
    } else if (previous) {
        view.hidden = previous.boolValue;
        objc_setAssociatedObject(view,QTHiddenBefore,nil,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}
static void QTNavigationViews(UIView *view,NSUInteger depth) {
    if (![view isKindOfClass:UIView.class] || depth>4) return;
    NSString *token = view.accessibilityIdentifier.lowercaseString ?: @"";
    BOOL hide = (QTOn(@"bell") && QTContains(token,@[@"notification",@"inbox"])) ||
                (QTOn(@"cast") && [token containsString:@"playbackroute"]);
    QTHide(view,hide);
    for (UIView *child in view.subviews) QTNavigationViews(child,depth+1);
}
static void QTCollectionViews(UIView *view,BOOL hide,NSUInteger depth) {
    if (!view || depth>5) return;
    if ([view isKindOfClass:UICollectionView.class]) { QTHide(view,hide); return; }
    for (UIView *child in view.subviews) QTCollectionViews(child,hide,depth+1);
}
static BOOL QTIsHome(id object) {
    NSString *direct = QTIdentifier(object,0);
    if ([direct isEqualToString:@"fewhat_to_watch"]) return YES;
    for (NSArray *path in @[@[@"navigationEndpoint",@"browseEndpoint",@"browseId"],
        @[@"endpoint",@"browseEndpoint",@"browseId"], @[@"browseEndpoint",@"browseId"]]) {
        id value = QTPath(object,path);
        if ([value isKindOfClass:NSString.class] && [value isEqualToString:@"FEwhat_to_watch"]) return YES;
    }
    return NO;
}
void QTInstallFeatures(void) {
    // Core experiment: filter only explicit player-response ad arrays. Preserve
    // request context, spam-signal generation, client identity and auth unchanged.
    for (NSString *getter in @[@"playerAdsArray",@"adSlotsArray",@"adPlacementsArray"]) {
        QTHook(@"YTIPlayerResponse",getter,@"@",^id(IMP old,SEL sel) {
            return ^id(id object) {
                id original = ((id (*)(id,SEL))old)(object,sel);
                if (QTOn(@"playerAds") && [original isKindOfClass:NSArray.class]) {
                    if ([original count]) QTCount(@"nonempty player-ad arrays filtered");
                    return [NSMutableArray array];
                }
                return original;
            };
        });
    }
    for (NSArray *pair in @[@[@"YTISectionListRenderer",@"contentsArray"],
        @[@"YTIItemSectionRenderer",@"contentsArray"],@[@"YTIHorizontalListRenderer",@"itemsArray"],
        @[@"YTIRichGridRenderer",@"contentsArray"]]) QTFilterGetter(pair[0],pair[1]);

    // Companion renderers are separate from player ad scheduling.
    for (NSString *getter in @[@"hasCompanionAdRenderer",@"hasAppPromoCompanionAdRenderer",@"hasShoppingCompanionAdRenderer"])
        QTBoolHook(@"YTIWatchNextSecondaryResults",getter,@"feedAds",NO);

    QTHook(@"YTPivotBarView",@"setRenderer:",@"v@",^id(IMP old,SEL sel) {
        return ^(id object,id renderer) {
            id candidate = renderer;
            id items = QTGet(renderer,@"itemsArray");
            SEL setter = NSSelectorFromString(@"setItemsArray:");
            if ([items isKindOfClass:NSArray.class] && QTMatches(renderer,setter,@"v@") &&
                (QTOn(@"shortsTab") || QTOn(@"create"))) {
                NSMutableArray *kept = [NSMutableArray array];
                for (id item in items) {
                    NSString *token = QTIdentifier(item,0);
                    BOOL remove = (QTOn(@"shortsTab") && QTContains(token,@[@"shorts",@"reel"])) ||
                        (QTOn(@"create") && QTContains(token,@[@"creation",@"upload",@"create"]));
                    if (!remove) [kept addObject:item]; else QTCount(@"tabs filtered");
                }
                if (kept.count && kept.count != [items count] && [renderer conformsToProtocol:@protocol(NSCopying)]) {
                    candidate = [renderer copy];
                    ((void (*)(id,SEL,id))objc_msgSend)(candidate,setter,kept);
                }
            }
            ((void (*)(id,SEL,id))old)(object,sel,candidate);
        };
    });
    QTHook(@"YTRightNavigationButtons",@"layoutSubviews",@"v",^id(IMP old,SEL sel) {
        return ^(UIView *view) {
            ((void (*)(id,SEL))old)(view,sel);
            QTNavigationViews(view,0);
            id bell = QTGet(view,@"notificationButton");
            if ([bell isKindOfClass:UIView.class]) QTHide(bell,QTOn(@"bell"));
        };
    });
    for (NSString *cls in @[@"YTBrowseViewController",@"YTBrowseResponseViewController"]) {
        QTHook(cls,@"viewDidLayoutSubviews",@"v",^id(IMP old,SEL sel) {
            return ^(UIViewController *vc) {
                ((void (*)(id,SEL))old)(vc,sel);
                BOOL home = QTIsHome(vc) || QTIsHome(vc.parentViewController);
                QTCollectionViews(vc.view,home && QTOn(@"home"),0);
                if (home && QTOn(@"home")) QTCount(@"Home content hidden");
            };
        });
    }
    QTHook(@"YTWatchNextResultsViewController",@"setVisibleSections:",@"vQ",^id(IMP old,SEL sel) {
        return ^(id object,NSUInteger sections) {
            ((void (*)(id,SEL,NSUInteger))old)(object,sel,QTOn(@"related") ? 1 : sections);
            if (QTOn(@"related")) QTCount(@"related sections limited");
        };
    });
    QTHook(@"YTMainAppControlsOverlayView",@"layoutSubviews",@"v",^id(IMP old,SEL sel) {
        return ^(id object) {
            ((void (*)(id,SEL))old)(object,sel);
            id end = QTGet(object,@"endscreenView");
            if ([end isKindOfClass:UIView.class]) QTHide(end,QTOn(@"endscreen"));
        };
    });
    for (NSString *cls in @[@"YTEndscreenView",@"YTMainAppVideoPlayerOverlayView"]) {
        QTHook(cls,@"layoutSubviews",@"v",^id(IMP old,SEL sel) {
            return ^(UIView *view) {
                ((void (*)(id,SEL))old)(view,sel);
                if ([NSStringFromClass(view.class) containsString:@"Endscreen"]) QTHide(view,QTOn(@"endscreen"));
                else for (UIView *child in view.subviews) {
                    if (QTContains(child.accessibilityIdentifier.lowercaseString,@[@"endscreen",@"end_screen"]))
                        QTHide(child,QTOn(@"endscreen"));
                }
            };
        });
    }
    QTSuppressVoid(@"YTMealbarPromoController",@"showMealbarPromoWithEvent:",@"promos",YES);
    QTSuppressVoid(@"YTPromosheetController",@"presentPromosheetWithEvent:",@"promos",YES);
    QTBoolHook(@"YTPromoThrottleController",@"canShowThrottledPromo",@"promos",NO);
    QTSuppressVoid(@"YTWatchFlowController",@"playAutoplay",@"autoplay",NO);
    QTSuppressVoid(@"YTQueueController",@"triggerPendingAutoplay",@"autoplay",NO);
    for (NSString *cls in @[@"YTSettings",@"YTSettingsImpl",@"YTAutonavController"]) {
        QTBoolHook(cls,@"isAutoplayEnabled",@"autoplay",NO);
        QTBoolHook(cls,@"isAutonavEnabled",@"autoplay",NO);
    }
    for (NSString *cls in @[@"YTSettings",@"YTSettingsImpl",@"YTHotConfig"]) {
        QTBoolHook(cls,@"inlinePlaybackEnabled",@"previews",NO);
        QTBoolHook(cls,@"isInlinePlaybackEnabled",@"previews",NO);
    }
    QTBoolHook(@"YTIPlayabilityStatus",@"isPlayableInBackground",@"background",YES);
    QTBoolHook(@"MLVideo",@"playableInBackground",@"background",YES);
    QTBoolHook(@"YTIBackgroundOfflineSettingCategoryEntryRenderer",@"isBackgroundEnabled",@"background",YES);
    QTBoolHook(@"YTIIosMediaHotConfig",@"enablePictureInPicture",@"pip",YES);
    QTBoolHook(@"YTIIosMediaHotConfig",@"enablePipForNonPremiumUsers",@"pip",YES);
    QTBoolHook(@"YTIPlayabilityStatus",@"isPlayableInPictureInPicture",@"pip",YES);
    QTBoolHook(@"YTIPlayabilityStatus",@"hasPictureInPicture",@"pip",YES);
    // Observe, do not suppress, replace, or retry playback errors.
    QTHook(@"YTMainAppVideoPlayerOverlayViewController",@"handleError:",@"v@",^id(IMP old,SEL sel) {
        return ^(id object,NSError *error) {
            if ([error isKindOfClass:NSError.class]) {
                // Never serialize userInfo/descriptions: they can contain media URLs or tokens.
                NSString *kind = [error.domain isEqualToString:@"com.google.ios.youtube.ErrorDomain.playback"] ? @"YouTube" : @"other";
                QTCount([NSString stringWithFormat:@"playback error %@ code %ld",kind,(long)error.code]);
            }
            ((void (*)(id,SEL,id))old)(object,sel,error);
        };
    });
}
