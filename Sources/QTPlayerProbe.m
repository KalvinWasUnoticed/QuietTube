#import "QTCore.h"

// One hook, two modes: test 0 observes; test 1 skips coordinator creation.
// A failed diagnostic increment must not prevent the original call or return.
static void QTProbeCount(NSString *event) {
    @try { QTCount(event); }
    @catch (__unused NSException *exception) { /* instrumentation only */ }
}
void QTInstallPlayerProbe(void) {
    if (!QTOn(@"enabled") || (!QTOn(@"playerProbe") && !QTOn(@"playerExperiment1"))) return;
    // Test 0 on the user device recorded three calls and three object returns.
    // That validates activity, not whether suppressing creation is safe.
    // QTHook checks runtime availability, zero explicit arguments and object ABI.
    QTHook(@"YTLocalPlaybackController",@"createAdsPlaybackCoordinator",@"@",^id(IMP old,SEL sel) {
        return ^id(id object) {
            if (QTOn(@"playerExperiment1")) {
                QTProbeCount(@"player test 1 coordinator creation suppressed");
                return nil;
            }
            QTProbeCount(@"player probe coordinator call entered");
            // Exactly one call. No catch around native code, no substituted result.
            id coordinator = ((id (*)(id,SEL))old)(object,sel);
            QTProbeCount(coordinator ? @"player probe coordinator returned object" : @"player probe coordinator returned nil");
            return coordinator;
        };
    });
}
