#import "QTCore.h"
NSArray<NSDictionary *> *QTSettingsRows(NSString *group);
NSString *QTSettingTitle(NSString *key);
NSDictionary<NSString *,NSNumber *> *QTSettingChanges(NSString *key, BOOL enabled);
NSDictionary<NSString *,NSNumber *> *QTPresetChanges(NSString *name);
void QTSaveSettings(NSDictionary<NSString *,NSNumber *> *changes);
BOOL QTSavedSetting(NSString *key);
