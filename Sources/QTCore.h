#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <objc/message.h>

BOOL QTOn(NSString *key);
void QTSet(NSString *key, BOOL value);
NSArray<NSDictionary *> *QTOptions(void);
void QTRegisterDefaults(void);
void QTCount(NSString *event);
NSString *QTDiagnostics(void);
id QTGet(id object, NSString *selector);
BOOL QTBool(id object, NSString *selector);
BOOL QTMatches(id object, SEL selector, NSString *signature);
void QTHook(NSString *className, NSString *selector, NSString *signature,
            id (^factory)(IMP original, SEL selector));
void QTBoolHook(NSString *className, NSString *selector, NSString *key, BOOL value);
void QTInstallFeatures(void);
void QTInstallSettings(void);
UIViewController *QTSettingsController(void);

void QTObserveUnmatchedElement(NSData *data);
void QTResetElementCapture(void);

void QTInstallPlainLogo(void);
// BEGIN 0.10 PLAYER PROBE
void QTInstallPlayerProbe(void);
// END 0.10 PLAYER PROBE
