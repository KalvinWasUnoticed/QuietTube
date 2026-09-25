#ifndef QT_DIAGNOSTIC_POLICY_H
#define QT_DIAGNOSTIC_POLICY_H
#include <stddef.h>
#include <math.h>
enum { QTDPFileLimit=262144, QTDPFiles=3, QTDPQueueLimit=64, QTDPRateLimit=30 };
static inline int QTDPAdmission(size_t pending, size_t rate, int critical) {
    return pending<(size_t)(critical?QTDPQueueLimit:QTDPQueueLimit-8) && rate<(size_t)(critical?QTDPRateLimit:QTDPRateLimit-6);
}
static inline int QTDPFits(size_t current, size_t added) {
    return current<=QTDPFileLimit && added<=QTDPFileLimit-current;
}
static inline int QTDPRecent(double timestamp, double now) {
    return isfinite(timestamp) && isfinite(now) && timestamp>=now-7*24*60*60 && timestamp<=now+60;
}
#endif
