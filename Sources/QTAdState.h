#ifndef QT_AD_STATE_H
#define QT_AD_STATE_H
/* Pure status logic: an enabled preference alone is never "effective blocking". */
typedef enum { QTAdOff, QTAdStopped, QTAdPending, QTAdPartial, QTAdInstalled } QTAdInstallState;
static QTAdInstallState QTAdState(int master, int requested, int stopped, int player, int feed) {
    if (!master || !requested) return QTAdOff;
    if (stopped) return QTAdStopped;
    if (player && feed) return QTAdInstalled;
    if (player || feed) return QTAdPartial;
    return QTAdPending;
}
static const char *QTAdStateName(QTAdInstallState state) {
    switch (state) {
        case QTAdOff: return "OFF";
        case QTAdStopped: return "SESSION SAFETY PAUSE - saved settings unchanged; restart to retry";
        case QTAdPending: return "WAITING/UNAVAILABLE - no complete workaround hook groups installed";
        case QTAdPartial: return "PARTIAL - a workaround hook group is unavailable";
        case QTAdInstalled: return "PLAYER AND FEED HOOKS INSTALLED - invocation/removal not implied";
    }
    return "UNKNOWN";
}
#endif
