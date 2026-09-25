#import "QTPreferences.h"

void QTInitializePreferences(NSUserDefaults *store, NSArray<NSDictionary *> *options) {
    NSString *prefix=@"QuietTube.v1.";
    NSString *marker=@"QuietTube.preferences.initialized";
    // Read before registering any fallback defaults. A saved false is NOT absent.
    // The old recovery marker is evidence of an existing installation only;
    // the destructive historical migration must never run again.
    BOOL existing=[store objectForKey:marker]!=nil ||
                  [store objectForKey:@"QuietTube.recovery02.initialized"]!=nil ||
                  [store objectForKey:[prefix stringByAppendingString:@"enabled"]]!=nil;
    for (NSDictionary *option in options) {
        if ([store objectForKey:[prefix stringByAppendingString:option[@"key"]]]!=nil) existing=YES;
    }
    NSMutableDictionary<NSString *,NSNumber *> *initial=[NSMutableDictionary dictionary];
    initial[@"enabled"]=@(!existing);
    for (NSDictionary *option in options) {
        NSString *key=option[@"key"];
        BOOL primary=[key isEqualToString:@"adTest"] || [key isEqualToString:@"feedAds"];
        // New installs: both protections ON. Older/incomplete installations:
        // do not silently enable a missing protection flag during an upgrade.
        initial[key]=primary ? @(!existing) : @([option[@"default"] boolValue]);
    }
    for (NSString *key in initial) {
        NSString *full=[prefix stringByAppendingString:key];
        if ([store objectForKey:full]==nil) [store setBool:[initial[key] boolValue] forKey:full];
    }
    if ([store objectForKey:marker]==nil) [store setBool:YES forKey:marker];
}
