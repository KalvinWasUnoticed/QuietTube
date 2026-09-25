// Separate-process persistence probe of the real initializer, with an isolated suite.
#import "../Sources/QTPreferences.h"
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
int main(int argc, const char *argv[]) {
    @autoreleasepool {
        assert(argc==6);
        NSString *name=[NSString stringWithUTF8String:argv[1]];
        assert([name hasPrefix:@"QuietTube.audit-tests."]);
        NSString *mode=[NSString stringWithUTF8String:argv[2]];
        NSData *data=[NSData dataWithContentsOfFile:[NSString stringWithUTF8String:argv[3]]];
        NSArray *options=[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        assert([options isKindOfClass:NSArray.class]);
        unsigned long long bits=strtoull(argv[4],NULL,10);
        BOOL fresh=atoi(argv[5])!=0;
        NSUserDefaults *store=[[NSUserDefaults alloc] initWithSuiteName:name];
        if ([mode isEqualToString:@"clean"]) {
            [store removePersistentDomainForName:name];
        } else {
            QTInitializePreferences(store,options);
            NSMutableArray *keys=[NSMutableArray arrayWithObject:@"enabled"];
            for (NSDictionary *option in options) [keys addObject:option[@"key"]];
            assert(keys.count<64);
            if (fresh) {
                assert([store boolForKey:@"QuietTube.v1.enabled"]);
                for (NSDictionary *option in options) assert([store boolForKey:[@"QuietTube.v1." stringByAppendingString:option[@"key"]]]==[option[@"default"] boolValue]);
            }
            for (NSUInteger i=0;i<keys.count;i++) {
                NSString *key=[@"QuietTube.v1." stringByAppendingString:keys[i]];
                BOOL expected=(bits & (1ULL<<i))!=0;
                if ([mode isEqualToString:@"write"]) [store setBool:expected forKey:key];
                else assert([store boolForKey:key]==expected);
            }
            if ([mode isEqualToString:@"write"]) [store setObject:@"untouched" forKey:@"unrelated.setting"];
            else assert([[store stringForKey:@"unrelated.setting"] isEqualToString:@"untouched"]);
        }
        // Flush only in this test to make subprocess ordering deterministic.
        // This does not simulate iOS force-kill timing or storage loss.
        assert([store synchronize]);
    }
    return 0;
}
