#import <Foundation/Foundation.h>
// Initialize absent values only. Existing YES and NO values are equally binding.
void QTInitializePreferences(NSUserDefaults *store, NSArray<NSDictionary *> *options);
