#ifndef QT_INSERTION_POLICY_H
#define QT_INSERTION_POLICY_H
#include <stddef.h>
static int QTInsertionMayFilter(int profileActive, int feedAds, size_t scopeDepth) {
    return profileActive && feedAds && scopeDepth>0;
}
static int QTInsertionBatchWithinLimit(size_t count) { return count>0 && count<=512; }
static int QTInsertionRejectEntry(int exactElementClass, int explicitAdMarker) {
    return exactElementClass && explicitAdMarker;
}
#endif
