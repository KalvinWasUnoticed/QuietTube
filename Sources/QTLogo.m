#import "QTCore.h"

// Native default-logo reset only: do not intercept or rescale the default image.
static _Thread_local BOOL QTLogoResetting;
static BOOL QTResetNativeLogo(id receiver) {
    SEL reset = NSSelectorFromString(@"updateToDefaultLogo");
    if (![NSThread isMainThread] || QTLogoResetting || !QTMatches(receiver,reset,@"v")) return NO;
    QTLogoResetting=YES;
    @try {
        ((void (*)(id,SEL))objc_msgSend)(receiver,reset);
        return YES;
    } @catch (__unused NSException *exception) {
        QTCount(@"native logo reset failed — kept original"); return NO;
    } @finally { QTLogoResetting=NO; }
}
void QTInstallPlainLogo(void) {
    if (!QTOn(@"plainLogo")) return;
    // Ownership and encodings are recorded in BASE-LOGO-ABI.json from the supplied
    // 21.38.2 binary. Runtime signature checks still gate installation.
    // Route event/entity and animated logo paths through the app's own reset.
    QTHook(@"YTHeaderLogoControllerImpl",@"updateLogoFromNitrateIfNeeded",@"v",^id(IMP old,SEL sel) {
        return ^(id object) {
            if (QTResetNativeLogo(object)) { QTCount(@"event logo replaced by native default"); return; }
            ((void (*)(id,SEL))old)(object,sel);
        };
    });
    QTHook(@"YTHeaderLogoControllerImpl",@"updateLogoWithLottieAnimation:",@"v@",^id(IMP old,SEL sel) {
        return ^(id object,id animation) {
            if (QTResetNativeLogo(object)) { QTCount(@"animated logo replaced by native default"); return; }
            ((void (*)(id,SEL,id))old)(object,sel,animation);
        };
    });
    // No generic UIImageView, title or layout hooks: other header content is untouched.
}
