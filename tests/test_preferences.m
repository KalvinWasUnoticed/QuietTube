// Foundation-only test of the actual initializer. Runs on the macOS build runner.
#import <Foundation/Foundation.h>
#import "../Sources/QTPreferences.h"
#include <assert.h>
#include <stdio.h>

static NSArray *Options(void) {
    return @[@{@"key":@"adTest",@"default":@YES},@{@"key":@"feedAds",@"default":@YES},
             @{@"key":@"background",@"default":@NO},@{@"key":@"plainLogo",@"default":@YES}];
}
int main(void) {
    @autoreleasepool {
        NSString *name=[@"QuietTube.preference-tests." stringByAppendingString:NSUUID.UUID.UUIDString];
        NSUserDefaults *d=[[NSUserDefaults alloc] initWithSuiteName:name];
        [d removePersistentDomainForName:name];
        QTInitializePreferences(d,Options());
        assert([d boolForKey:@"QuietTube.v1.enabled"]);
        assert([d boolForKey:@"QuietTube.v1.adTest"]);
        assert([d boolForKey:@"QuietTube.v1.feedAds"]);
        assert(![d boolForKey:@"QuietTube.v1.background"]);
        // All ON/OFF combinations survive repeated initialization / new store objects.
        for (unsigned bits=0;bits<32;bits++) {
            NSArray *keys=@[@"enabled",@"adTest",@"feedAds",@"background",@"plainLogo"];
            for (NSUInteger i=0;i<keys.count;i++) [d setBool:(bits&(1u<<i))!=0 forKey:[@"QuietTube.v1." stringByAppendingString:keys[i]];
            for (unsigned launch=0;launch<20;launch++) {
                NSUserDefaults *reopened=[[NSUserDefaults alloc] initWithSuiteName:name];
                QTInitializePreferences(reopened,Options());
                for (NSUInteger i=0;i<keys.count;i++) assert([reopened boolForKey:[@"QuietTube.v1." stringByAppendingString:keys[i]]]==((bits&(1u<<i))!=0));
            }
        }
        [d removePersistentDomainForName:name];
        [d setBool:YES forKey:@"QuietTube.recovery02.initialized"];
        QTInitializePreferences(d,Options());
        assert(![d boolForKey:@"QuietTube.v1.enabled"]);
        assert(![d boolForKey:@"QuietTube.v1.adTest"]);
        assert(![d boolForKey:@"QuietTube.v1.feedAds"]);
        // Partial old preferences, no marker: preserve the user's single choice.
        [d removePersistentDomainForName:name];
        [d setBool:YES forKey:@"QuietTube.v1.background"];
        QTInitializePreferences(d,Options());
        assert([d boolForKey:@"QuietTube.v1.background"]);
        assert(![d boolForKey:@"QuietTube.v1.adTest"]);
        // False must also classify an installation as existing.
        [d removePersistentDomainForName:name];
        [d setBool:NO forKey:@"QuietTube.v1.feedAds"];
        QTInitializePreferences(d,Options());
        assert(![d boolForKey:@"QuietTube.v1.feedAds"]);
        assert(![d boolForKey:@"QuietTube.v1.adTest"]);
        [d removePersistentDomainForName:name];
        puts("Foundation preference tests passed: fresh/legacy/partial states and 32 choices x 20 reinitializations. Not an iOS process-lifecycle test.");
    }
    return 0;
}
