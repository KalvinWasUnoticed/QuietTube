# Runtime function and interface inventory

Entry points and signatures, not measured code coverage. The [1.1.0 audit](AUDIT-1.1.0.md) records what was reviewed and tested. Inline blocks are reviewed with the function that owns them.

## `QTAdProfile.m`

- `QTAdPrepare`
- `QTAdRecord`
- `QTAdActive`
- `QTAdProfilePaused`
- `QTAdProfileActive`
- `QTAdPlaybackError`
- `QTAdReport`
- `QTInstallAdProfile`
- `QTHook`
- Objective-C `- (instancetype)initWithServiceRegistryScope:(id)scope delegate:(id)delegate;`

## `QTAdState.h`

- `QTAdState`
- `QTAdStateName`

## `QTCore.m`

- `QTOptions`
- `QTRegisterDefaults`
- `QTOn`
- `QTSet`
- `QTCount`
- `QTStatus`
- `QTType`
- `QTMatches`
- `QTGet`
- `QTBool`
- `QTHook`
- `QTBoolHook`
- `QTHook`
- `QTResetElementCapture`
- `QTObserveUnmatchedElement`
- `QTDiagnostics`
- `QTSettingsPendingRestart`
- `QTStart (constructor)`

## `QTDiagnosticLog.m`

- `QTDPrepare`
- `QTDIdentifier`
- `QTDSanitize`
- `QTDPath`
- `QTDRead`
- `QTDEncode`
- `QTDProtect`
- `QTDPrune`
- `QTDEnsureDirectory`
- `QTDWrite`
- `QTDRow`
- `QTDConfigure`
- `QTDEnabled`
- `QTDStart`
- `QTDStop`
- `QTDSample`
- `QTDEvent`
- `QTDError`
- `QTDExport`
- `QTDClear`

## `QTDiagnosticPolicy.h`

- `QTDPAdmission`
- `QTDPFits`
- `QTDPRecent`

## `QTDiagnosticsBridge.m`

- `QTDClass`
- `QTDInspectElement`
- `QTDWalk`
- `QTDDiagnosticBoundary`
- `QTDDiagnosticMutation`
- `QTDDiagnosticPlayer`

## `QTFeatures.m`

- `QTDepthLimit`
- `QTShelfTitle`
- `QTDropNode`
- `QTFilteredArray`
- `QTFilteredNode`
- `QTNoArgAction`
- `QTHook`
- `QTInstallFeatures`
- `QTHook`
- `QTHook`

## `QTFeedInsertion.m`

- `QTFeedPrepare`
- `QTFeedAdd`
- `QTFeedInsertionHandlerInstalled`
- `QTFeedExactABI`
- `QTFeedFilteredEntries`
- `QTInstallFeedInsertion`
- `QTHook`
- `QTHook`
- `QTFeedInsertionReport`

## `QTFeedRules.h`

- `QTTokenChar`
- `QTTokenPresent`
- `QTPlaylistIDChar`
- `QTIsRadioPlaylistID`
- `QTHasRadioPlaylistQuery`
- `QTHasExactWatchAgainText`
- `QTClassifyElementBytes`

## `QTInsertionPolicy.h`

- `QTInsertionMayFilter`
- `QTInsertionBatchWithinLimit`
- `QTInsertionRejectEntry`

## `QTLogo.m`

- `QTResetNativeLogo`
- `QTInstallPlainLogo`
- `QTHook`
- `QTHook`

## `QTMutationTrace.m`

- `QTTraceNames`
- `QTTestFlags`
- `QTPrepareAdTest`
- `QTTracePrepare`
- `QTTraceClass`
- `QTTraceElement`
- `QTTraceShape`
- `QTTraceRecord`
- `QTTraceFeedInsertion`
- `QTTraceHook`
- `QTInstallMutationTrace`
- `QTTraceHook`
- `QTTraceHook`
- `QTTraceHook`
- `QTTraceHook`
- `QTTraceHook`
- `QTMutationReport`

## `QTPreferences.m`

- `QTInitializePreferences`

## `QTSettings.m`

- `QTDExport`
- `QTSettingsController`
- `QTAppendEntry`
- `QTInstallSettings`
- `QTHook`
- `QTHook`
- Objective-C `- (void)viewDidLoad`
- Objective-C `- (void)viewWillAppear:(BOOL)animated`
- Objective-C `- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section`
- Objective-C `- (NSString *)tableView:(UITableView *)tv titleForHeaderInSection:(NSInteger)section`
- Objective-C `- (NSString *)tableView:(UITableView *)tv titleForFooterInSection:(NSInteger)section`
- Objective-C `- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)index`
- Objective-C `- (void)closeControls`
- Objective-C `- (void)showNotice:(NSString *)message`
- Objective-C `- (void)changed:(UISwitch *)sender`
- Objective-C `- (void)applyPreset`
- Objective-C `- (void)showText:(NSString *)content title:(NSString *)title`
- Objective-C `- (void)tableView:(UITableView *)tv didSelectRowAtIndexPath:(NSIndexPath *)index`

## `QTSettingsModel.m`

- `QTCatalog`
- `QTSettingsRows`
- `QTSettingTitle`
- `QTSavedSetting`
- `QTSaveSettings`

## `QTTemplateScan.h`

- `QTTemplateChar`
- `QTIdentifierFamily`
- `QTExtractTemplateNames`

