#import <Foundation/Foundation.h>
#import <dispatch/dispatch.h>
// Manual session state is transient; no user preferences are changed.
typedef NS_ENUM(NSUInteger, QTDiagnosticEvent) {
    QTDEStart, QTDEStop, QTDEApp, QTDEPlaybackError, QTDEPlayer,
    QTDEMutation, QTDEFeedBoundary, QTDEElement, QTDEHook, QTDECount
};
void QTDConfigure(NSString *directory);
BOOL QTDEnabled(void);
BOOL QTDStart(void);
void QTDStop(void);
void QTDEvent(QTDiagnosticEvent event, NSDictionary *fields);
BOOL QTDSample(void);
void QTDError(NSError *error);
// Completions run on the logging queue, NOT the main queue. No sync UI waits.
void QTDExport(void (^completion)(NSString *report));
void QTDClear(void (^completion)(void));
// Foundation-only redaction entry point, shared by write and export validation.
NSDictionary *QTDSanitize(NSDictionary *fields);
