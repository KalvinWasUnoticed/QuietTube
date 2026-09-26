// Execute the production Foundation settings model; isolate its persistence boundary.
#import "../Sources/QTSettingsModel.h"
#include <assert.h>
#include <stdio.h>
static NSArray *options;
static NSMutableDictionary *writes;
NSArray<NSDictionary *> *QTOptions(void) { return options; }
void QTSet(NSString *key, BOOL value) { writes[key]=@(value); }
int main(int argc, const char *argv[]) {
    @autoreleasepool {
        assert(argc==2);
        NSData *data=[NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[1]]];
        options=[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        assert([options isKindOfClass:NSArray.class]);
        writes=[NSMutableDictionary dictionary];
        NSMutableSet *known=[NSMutableSet setWithObject:@"enabled"];
        for (NSDictionary *option in options) [known addObject:option[@"key"]];
        NSMutableSet *seen=[NSMutableSet set];
        for (NSString *group in @[@"Ads",@"Feed",@"Playback",@"Appearance",@"Advanced",@"Troubleshooting"]) {
            for (NSDictionary *row in QTSettingsRows(group)) {
                assert([known containsObject:row[@"key"]]);
                assert(![seen containsObject:row[@"key"]]);
                [seen addObject:row[@"key"]];
                assert([row[@"group"] isEqualToString:group]);
                assert([row[@"title"] length]>0 && [row[@"note"] length]>0);
                assert([QTSettingTitle(row[@"key"]) isEqualToString:row[@"title"]]);
            }
        }
        assert(seen.count==options.count);
        assert(QTSettingsRows(@"unknown").count==0);
        assert([QTSettingTitle(@"unknown") isEqualToString:@"unknown"]);
        assert([QTSettingTitle(@"enabled") isEqualToString:@"Enable QuietTube"]);
        NSSet *extended=[NSSet setWithArray:@[@"topicsShelves",@"edgeCards",@"playables",@"eventPromos",@"inspectElements",@"displayAds",@"mixes",@"watchAgain"]];
        for (NSString *key in known) {
            for (unsigned enabled=0;enabled<2;enabled++) {
                NSMutableDictionary *expected=[NSMutableDictionary dictionaryWithObject:@(enabled!=0) forKey:key];
                if (enabled && [extended containsObject:key]) expected[@"extendedFeed"]=@YES;
                if (enabled && [key isEqualToString:@"displayAds"]) expected[@"feedAds"]=@YES;
                [writes removeAllObjects];
                NSDictionary *changes=QTSettingChanges(key,enabled!=0);
                assert([changes isEqualToDictionary:expected]);
                assert(writes.count==0); // Preview is pure.
                QTSaveSettings(changes);
                assert([writes isEqualToDictionary:expected]);
            }
        }
        for (NSString *name in @[@"Ads & essentials",@"Focused feed"]) {
            [writes removeAllObjects];
            NSDictionary *preset=QTPresetChanges(name);
            assert(writes.count==0);
            assert(preset.count==(NSUInteger)([name isEqualToString:@"Focused feed"]?16:9));
            assert(!preset[@"background"] && !preset[@"autoplay"]);
            assert(![preset[@"mutationTrace"] boolValue] && ![preset[@"inspectElements"] boolValue] && ![preset[@"enhancedLogging"] boolValue]);
            for (NSString *key in @[@"enabled",@"adTest",@"feedAds",@"displayAds",@"extendedFeed",@"plainLogo"]) assert([preset[key] boolValue]);
            QTSaveSettings(preset);
            assert([writes isEqualToDictionary:preset]);
        }
        assert(QTPresetChanges(@"unknown").count==0);
        [writes removeAllObjects];
        QTSaveSettings(@{@"unknown":@YES,@"adTest":@NO});
        assert(writes.count==1 && ![writes[@"adTest"] boolValue]);
        // Read-path test without writing the user's persistent preferences.
        NSUserDefaults *store=NSUserDefaults.standardUserDefaults;
        NSDictionary *before=[store volatileDomainForName:NSArgumentDomain];
        for (unsigned enabled=0;enabled<2;enabled++) {
            NSMutableDictionary *domain=[before mutableCopy];
            for (NSString *key in known) domain[[@"QuietTube.v1." stringByAppendingString:key]]=@(enabled!=0);
            [store setVolatileDomain:domain forName:NSArgumentDomain];
            for (NSString *key in known) assert(QTSavedSetting(key)==(enabled!=0));
        }
        [store setVolatileDomain:before forName:NSArgumentDomain];
        puts("Production settings model passed: catalog, all toggles/dependencies, presets, preview purity, restricted writes and saved reads. UIKit not executed.");
    }
    return 0;
}
