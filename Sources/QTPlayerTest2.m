#import "QTCore.h"

// Scoped to the exact config object read synchronously by the native factory.
// The factory wrapper retains config for the entire scoped call. No config writes.
static _Thread_local __unsafe_unretained id QTNoOpConfig;
static void QTTest2Count(NSString *event) {
    @try { QTCount(event); }
    @catch (__unused NSException *exception) { }
}
void QTInstallPlayerTest2(void) {
    if (!QTOn(@"enabled") || !QTOn(@"playerExperiment2")) return;
    Class configClass = NSClassFromString(@"YTIIosPlayerConfig");
    Class noOpClass = NSClassFromString(@"YTNoOpAdsPlaybackCoordinator");
    SEL flag = NSSelectorFromString(@"useNoOpAdsCoordinator");
    // Protobuf getters can be dynamically resolved; metadata alone isn't enough.
    id sample = nil;
    @try { sample = [[configClass alloc] init]; }
    @catch (__unused NSException *exception) { }
    if (!noOpClass || !QTMatches(sample,flag,@"B")) {
        QTTest2Count(@"player test 2 unavailable config getter — native unchanged");
        return;
    }
    IMP before = class_getMethodImplementation(configClass,flag);
    QTHook(@"YTIIosPlayerConfig",@"useNoOpAdsCoordinator",@"B",^id(IMP old,SEL sel) {
        return ^BOOL(id config) {
            if (QTNoOpConfig && config == QTNoOpConfig) {
                QTTest2Count(@"player test 2 scoped no-op flag read");
                return YES;
            }
            return ((BOOL (*)(id,SEL))old)(config,sel);
        };
    });
    if (class_getMethodImplementation(configClass,flag) == before) {
        QTTest2Count(@"player test 2 flag hook not installed — native unchanged");
        return;
    }
    QTHook(@"YTRealAdsPlayerServices",
        @"adsPlaybackCoordinatorWithOverlayManager:delegate:parentResponder:contentPlayerResponse:",@"@@@@@",
        ^id(IMP old,SEL sel) {
            return ^id(id object,id overlay,id delegate,id parent,id response) {
                QTTest2Count(@"player test 2 native factory entered");
                id config = QTGet(QTGet(QTGet(response,@"playerData"),@"playerConfig"),@"iosPlayerConfig");
                if (![config isKindOfClass:configClass]) config = nil;
                if (!config) QTTest2Count(@"player test 2 missing config — native selection");
                id previous = QTNoOpConfig;
                id result;
                @try {
                    QTNoOpConfig = config;
                    // Native factory preserves scope, delegate and its own initializer.
                    // Never return a synthetic nil, manually instantiate a coordinator,
                    // call completion delegates, or mutate the config/response.
                    result = ((id (*)(id,SEL,id,id,id,id))old)(object,sel,overlay,delegate,parent,response);
                } @finally {
                    QTNoOpConfig = previous;
                }
                if ([result isKindOfClass:noOpClass])
                    QTTest2Count(@"player test 2 native no-op coordinator returned");
                else QTTest2Count(result ? @"player test 2 other coordinator returned" : @"player test 2 native factory returned nil");
                return result;
            };
        });
}
