#import <Foundation/Foundation.h>
#import <objc/runtime.h>
// Foundation-only declarations of existing signature-checked native getters.
// Implemented in QTCore.m; no new reflection or mutation API.
id QTGet(id object, NSString *selector);
BOOL QTBool(id object, NSString *selector);
BOOL QTMatches(id object, SEL selector, NSString *signature);
