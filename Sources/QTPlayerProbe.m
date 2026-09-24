#import "QTCore.h"

// Test 0 observes one candidate entry point. It does not disable any ad logic.
// A failed diagnostic increment must not prevent the original call or return.
static void QTProbeCount(NSString *event) {
    @try { QTCount(event); }
    @catch (__unused NSException *exception) { /* instrumentation only */ }
}
void QTInstallPlayerProbe(void) {
    if (!QTOn(@"enabled") || !QTOn(@"playerProbe")) return;
    // Public-source candidate, not statically verified against this executable.
    // QTHook checks runtime availability, zero explicit arguments and object ABI.
    QTHook(@"YTLocalPlaybackController",@"createAdsPlaybackCoordinator",@"@",^id(IMP old,SEL sel) {
        return ^id(id object) {
            QTProbeCount(@"player probe coordinator call entered");
            // Exactly one call. No catch around native code, no substituted result.
            id coordinator = ((id (*)(id,SEL))old)(object,sel);
            QTProbeCount(coordinator ? @"player probe coordinator returned object" : @"player probe coordinator returned nil");
            return coordinator;
        };
    });
}
