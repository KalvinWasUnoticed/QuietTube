#import "QTSettingsModel.h"
// Presentation-only catalog: keep legacy preference keys and runtime defaults.
static NSArray<NSDictionary *> *QTCatalog(void) {
    static NSArray *rows;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        NSArray *definitions=@[
          @[@"adTest",@"Ads",@"Block video ads",@"Also enables the dynamic feed-ad fix when Block feed ads is on. May pause for the current session after a playback error. Your choice stays saved; reopen the app to retry."],
          @[@"feedAds",@"Ads",@"Block feed ads",@"Hide recognized sponsored items. For ads inserted after minimizing, also enable Block video ads."],
          @[@"displayAds",@"Ads",@"Additional ad formats",@"Broader image-ad matching. May also hide nested promotional content. Enabling also enables feed ads and extended matching."],
          @[@"shorts",@"Feed",@"Hide Shorts shelves",@"Does not remove the Shorts tab or every Shorts surface."],
          @[@"mixes",@"Feed",@"Hide Mixes",@"Hide Mix recommendations. Nested Mix links may also match."],
          @[@"watchAgain",@"Feed",@"Hide Watch it again",@"Hide recognized shelves without deleting watch history. Title matching currently supports English."],
          @[@"topicsShelves",@"Feed",@"Hide topic suggestions",@"Hide Explore more topics and recognized topic shelves. Other chip shelves may also match."],
          @[@"edgeCards",@"Feed",@"Hide large portrait cards",@"Hide recognized edge-to-edge and inline portrait cards. Some smaller portrait cards may also match."],
          @[@"playables",@"Feed",@"Hide Playables",@"Hide recognized game shelves."],
          @[@"eventPromos",@"Feed",@"Hide promotional shelves",@"Hide recognized featured and event cards. Does not change the logo."],
          @[@"background",@"Playback",@"Background audio",@"Keep audio playing when you leave the app. Use YouTube’s own setting for Picture in Picture."],
          @[@"autoplay",@"Playback",@"Stop the next video",@"Prevent selected automatic next-video actions, not feed previews."],
          @[@"plainLogo",@"Appearance",@"Classic YouTube logo",@"Replace seasonal and event logo artwork."],
          @[@"extendedFeed",@"Advanced",@"Extended feed matching",@"Needed by additional ad formats and most feed cleanup options. Disabling pauses those options without erasing their preferences."],
          @[@"mutationTrace",@"Troubleshooting",@"Record feed activity",@"Local, bounded timing and class/template details. No automatic upload. Review before sharing."],
          @[@"inspectElements",@"Troubleshooting",@"Record template clues",@"Local internal template-name capture. Review before sharing; enabling also enables extended matching."]
        ];
        NSMutableArray *a=[NSMutableArray array];
        for (NSArray *d in definitions) [a addObject:@{@"key":d[0],@"group":d[1],@"title":d[2],@"note":d[3]}];
        rows=[a copy];
    });
    return rows;
}
NSArray<NSDictionary *> *QTSettingsRows(NSString *group) {
    NSMutableArray *result=[NSMutableArray array];
    for (NSDictionary *row in QTCatalog()) if ([row[@"group"] isEqualToString:group]) [result addObject:row];
    return result;
}
NSString *QTSettingTitle(NSString *key) {
    if ([key isEqualToString:@"enabled"]) return @"Enable QuietTube";
    for (NSDictionary *row in QTCatalog()) if ([row[@"key"] isEqualToString:key]) return row[@"title"];
    return key;
}
BOOL QTSavedSetting(NSString *key) {
    return [NSUserDefaults.standardUserDefaults boolForKey:[@"QuietTube.v1." stringByAppendingString:key]];
}
NSDictionary<NSString *,NSNumber *> *QTSettingChanges(NSString *key, BOOL enabled) {
    NSMutableDictionary *changes=[NSMutableDictionary dictionaryWithObject:@(enabled) forKey:key];
    if (enabled && [@[@"topicsShelves",@"edgeCards",@"playables",@"eventPromos",@"inspectElements",@"displayAds",@"mixes",@"watchAgain"] containsObject:key]) changes[@"extendedFeed"]=@YES;
    if (enabled && [key isEqualToString:@"displayAds"]) changes[@"feedAds"]=@YES;
    return changes;
}
NSDictionary<NSString *,NSNumber *> *QTPresetChanges(NSString *name) {
    if (![@[@"Ads & essentials",@"Focused feed"] containsObject:name]) return @{};
    NSMutableDictionary *changes=[@{@"enabled":@YES,@"adTest":@YES,@"feedAds":@YES,@"displayAds":@YES,@"extendedFeed":@YES,@"plainLogo":@YES,@"mutationTrace":@NO,@"inspectElements":@NO,@"enhancedLogging":@NO} mutableCopy];
    if ([name isEqualToString:@"Focused feed"]) for (NSString *key in @[@"shorts",@"mixes",@"watchAgain",@"topicsShelves",@"edgeCards",@"playables",@"eventPromos"]) changes[key]=@YES;
    return changes;
}
void QTSaveSettings(NSDictionary<NSString *,NSNumber *> *changes) {
    // Restrict writes to known preferences. No reset, migration or hook install.
    NSMutableSet *known=[NSMutableSet setWithObject:@"enabled"];
    for (NSDictionary *option in QTOptions()) [known addObject:option[@"key"]];
    [known addObject:@"enhancedLogging"];
    for (NSString *key in changes) if ([known containsObject:key]) QTSet(key,[changes[key] boolValue]);
}
