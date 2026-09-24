#import "QTCore.h"
#include <math.h>

static UIImage *QTPlainLogoImage(id receiver) {
    // This getter belongs to the logo controller in the inspected 21.38.2 ABI.
    id nativeDefault = QTGet(receiver,@"defaultLogoImage");
    if ([nativeDefault isKindOfClass:UIImage.class]) {
        QTCount(@"plain logo native default used"); return nativeDefault;
    }
    // Fallback to the app's ordinary wordmark asset, not an event/entity image.
    NSInteger style = UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ? 1 : 0;
    SEL styleGetter = NSSelectorFromString(@"pageStyle");
    if (QTMatches(receiver,styleGetter,@"Q"))
        style = ((NSInteger (*)(id,SEL))objc_msgSend)(receiver,styleGetter);
    Class resources = NSClassFromString(@"YTUIResources");
    SEL asset = NSSelectorFromString(@"youtubeLogoWithPageStyle:");
    if (QTMatches(resources,asset,@"@Q")) {
        id image = ((id (*)(id,SEL,NSInteger))objc_msgSend)(resources,asset,style);
        if ([image isKindOfClass:UIImage.class]) { QTCount(@"plain logo native asset used"); return image; }
    }
    // Local fallback: the requested word, not a guessed event icon or a blank area.
    // Explicit colors follow the current page style at the image-update boundary.
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:22] ?: [UIFont boldSystemFontOfSize:21];
    NSDictionary *attributes = @{NSFontAttributeName:font,
        NSForegroundColorAttributeName:style == 1 ? UIColor.whiteColor : UIColor.blackColor};
    NSString *word = @"YouTube";
    CGSize size = [word sizeWithAttributes:attributes];
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc]
        initWithSize:CGSizeMake(ceil(size.width)+2,ceil(size.height)+2)];
    QTCount(@"plain logo text fallback used");
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [word drawAtPoint:CGPointMake(1,1) withAttributes:attributes];
    }];
}
static _Thread_local BOOL QTLogoRendering;
static UIImage *QTSafePlainLogoImage(id receiver) {
    if (![NSThread isMainThread] || QTLogoRendering) {
        QTCount(@"plain logo update skipped — thread or recursion guard"); return nil;
    }
    QTLogoRendering=YES;
    @try { return QTPlainLogoImage(receiver); }
    @catch (__unused NSException *exception) {
        QTCount(@"plain logo generation failed — kept original"); return nil;
    }
    @finally { QTLogoRendering=NO; }
}
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
    QTHook(@"YTHeaderLogoControllerImpl",@"updateLogoWithImage:needsRescaling:withYoodle:",@"v@BB",^id(IMP old,SEL sel) {
        return ^(id object,id image,BOOL scale,BOOL yoodle) {
            UIImage *plain = QTSafePlainLogoImage(object);
            QTCount(@"header logo image update intercepted");
            ((void (*)(id,SEL,id,BOOL,BOOL))old)(object,sel,plain ?: image,plain ? YES : scale,plain ? NO : yoodle);
        };
    });
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
