#import <Foundation/Foundation.h>
// Initialize absent values only. Existing YES and NO values are equally binding.
void QTInitializePreferences(NSUserDefaults *store, NSArray<NSDictionary *> *options);

// Shared preference interfaces; implementation remains in QTCore.m.
NSArray<NSDictionary *> *QTOptions(void);
void QTSet(NSString *key, BOOL value);
