from pathlib import Path
import json,re,unittest
from preservation import reviewed_source
R=Path(__file__).resolve().parents[1]
class DiagnosticTests(unittest.TestCase):
 def test_writer_fixed_schema_no_payload_dump(self):
  s=(R/'Sources/QTDiagnosticLog.m').read_text()
  for forbidden in ['localizedDescription','NSLog(', 'NSURLConnection','NSURLSession','QTSet(', 'description]']:
   self.assertNotIn(forbidden,s)
  # setBool is now used only for the persistent master via setObject, not direct setBool
  self.assertNotIn('setBool:',s)
  self.assertIn('for (NSString *key in @[',s)
  self.assertIn('QTDSanitize(value[@"fields"])',s)
  self.assertIn('QTDPRecent(',s)
 def test_disk_bounds_and_background_io(self):
  s=(R/'Sources/QTDiagnosticLog.m').read_text()
  self.assertIn('DISPATCH_QUEUE_SERIAL',s)
  self.assertIn('QTDPFits(',s)
  self.assertIn('NSFileTypeRegular',s)
  self.assertIn('NSURLIsExcludedFromBackupKey',s)
  self.assertIn('NSFileProtectionCompleteUntilFirstUserAuthentication',s)
  self.assertNotIn('dispatch_sync',s)
  self.assertIn('i<3',s)
 def test_manual_state_is_not_a_preference(self):
  s=(R/'Sources/QTDiagnosticLog.m').read_text()
  # Enhanced master is persistent (QTEnhancedKey via setObject), but transient QTDRecording stays in-memory.
  self.assertIn('QTEnhancedKey',s)
  self.assertIn('QTEnhancedEnabled',s)
  self.assertIn('if (!QTDRecording || event>=QTDECount) return;',s)
  start=(R/'Sources/QTCore.m').read_text().split('static void QTStart')[1]
  self.assertNotIn('QTDStart()',start)
  self.assertIn('QTDConfigure(',start)
 def test_clear_stops_admission_before_queued_deletion(self):
  s=(R/'Sources/QTDiagnosticLog.m').read_text().split('void QTDClear')[1]
  self.assertLess(s.index('QTDRecording=NO'),s.index('dispatch_async'))
  self.assertIn('removeItemAtPath:QTDPath', (R/'Sources/QTDiagnosticLog.m').read_text())
 def test_observer_is_read_only_bounded_and_scoped(self):
  s=(R/'Sources/QTDiagnosticsBridge.m').read_text()
  for forbidden in ['QTSet(', 'QTHook(', 'setValue:', 'setObject:', 'description]', 'serialize', 'performSelector:', 'videoId', 'playlistId']:
   self.assertNotIn(forbidden,s)
  self.assertIn('depth>3',s);self.assertIn('budget=12',s)
  self.assertIn('262144',s);self.assertIn('char names[4][97]',s)
  self.assertIn('QTDSample()',s)
 def test_lifecycle_and_ui_main_thread_export(self):
  core=(R/'Sources/QTCore.m').read_text()
  for name in ['UIApplicationDidBecomeActiveNotification','UIApplicationDidEnterBackgroundNotification','UIApplicationDidReceiveMemoryWarningNotification']:
   self.assertIn(name,core)
  s=(R/'Sources/QTSettings.m').read_text()
  # New 3-button UI: single master toggle + export + clear
  for name in ['toggleEnhancedLogging','exportDiagnostics','clearDiagnostics']:self.assertIn(name,s)
  self.assertNotIn('startDiagnostics',s)
  self.assertNotIn('stopDiagnostics',s)
  self.assertIn('sourceRect=CGRectMake',s)
  self.assertIn('self.diagnosticBusy',s)
  self.assertIn('QTDExport(^(NSString *report) { dispatch_async(dispatch_get_main_queue()',s)
  self.assertIn('isEqualToString:@"21.38.2"]) QTInstallFeatures();',s)
  self.assertIn('QTEnhancedStart',s)
  self.assertIn('QTEnhancedStop',s)
 def test_legacy_trace_does_not_turn_on_with_manual_logging(self):
  s=(R/'Sources/QTMutationTrace.m').read_text()
  self.assertIn('if (!QTOn(@"mutationTrace")) return;',s)
  self.assertIn('(!QTOn(@"mutationTrace") && !QTDEnabled())',s)
 def test_all_reviewed_deltas_are_present_and_reversible(self):
  d=json.loads((R/'tests/fixtures/diagnostics-delta.json').read_text())
  self.assertEqual(set(d),{'Sources/QTCore.m','Sources/QTFeatures.m','Sources/QTAdProfile.m','Sources/QTFeedInsertion.m','Sources/QTMutationTrace.m','Sources/QTSettings.m'})
  # Original 1.1.0 deltas are still present; 1.2.0 adds at least 3 more for QTCore and 2 more for QTSettings
  self.assertGreaterEqual(len(d['Sources/QTCore.m']), 7)
  self.assertGreaterEqual(len(d['Sources/QTSettings.m']), 8)
  # Current enhanced logger is present in the new files
  self.assertIn('QTEnhancedEnabled', (R/'Sources/QTDiagnosticLog.h').read_text())
  self.assertIn('QTEnhancedEnabled', (R/'Sources/QTDiagnosticLog.m').read_text())
  # Frozen source (after reversing all deltas) should still be clean of any diagnostics
  for name in ['Sources/QTFeatures.m','Sources/QTAdProfile.m','Sources/QTFeedInsertion.m','Sources/QTMutationTrace.m']:
   self.assertNotIn('QTDEnabled()',reviewed_source(name))
 def test_general_counters_now_have_a_cap(self):
  s=(R/'Sources/QTCore.m').read_text()
  self.assertIn('QTCounters.count>=128',s)
  self.assertIn('@\"additional counter events\"',s)
 def test_reservation_for_errors_and_safety_pause(self):
  s=(R/'Sources/QTDiagnosticLog.m').read_text()
  self.assertIn('event==QTDEPlaybackError',s)
  self.assertIn('QTDPAdmission(QTDPending,0,critical)',s)
 def test_native_logger_harness_is_compiled_and_executed(self):
  s=(R/'scripts/test_native.py').read_text()
  self.assertIn("logger=build('logger',['Sources/QTDiagnosticLog.m','tests/test_diagnostic_log.m'])",s)
  self.assertIn("subprocess.run([logger,str(temp/'diagnostic-store')]",s)
 def test_no_enum_function_name_collision(self):
  header=(R/'Sources/QTDiagnosticLog.h').read_text()
  body=header.split('typedef NS_ENUM')[1].split('};')[0]
  enums=set(re.findall(r'\bQTDE\w+\b',body))
  for p in (R/'Sources').glob('*.m'):
   functions=set(re.findall(r'^\s*(?:static\s+)?(?:void|BOOL|NSString\s*\*|NSDictionary\s*\*)\s*(QTD\w+)\(',p.read_text(),re.M))
   self.assertFalse(enums & functions,p.name)
 def test_observation_declarations_match_core_interfaces(self):
  header=(R/'Sources/QTObservationAccess.h').read_text()
  core=(R/'Sources/QTCore.h').read_text()
  for line in header.splitlines():
   if line.startswith(('id QTGet','BOOL QTBool','BOOL QTMatches')):self.assertIn(line,core)
  self.assertIn('tests/test_diagnostic_bridge.m',(R/'scripts/test_native.py').read_text())

 def test_export_geometry_framework_is_linked(self):
  ui=(R/'Sources/QTSettings.m').read_text()
  build=(R/'scripts/build.sh').read_text()
  self.assertIn('CGRectGetMidX',ui)
  self.assertIn('CGRectGetMidY',ui)
  frameworks=re.findall(r'-framework\s+(\w+)',build)
  for required in ['Foundation','UIKit','CoreGraphics']:
   self.assertIn(required,frameworks)
 def test_enhanced_logger_is_persistent_and_bounded(self):
  s=(R/'Sources/QTDiagnosticLog.m').read_text()
  self.assertIn('QTEnhancedEnabled',s)
  self.assertIn('QTEnhancedStart',s)
  self.assertIn('QTEnhancedStop',s)
  self.assertIn('quiettube.v1.enhancedlogging',s.lower())
  # Still 3 files x 256 KiB
  self.assertIn('i<3',s)
  self.assertIn('QTDPFileLimit',s)
  self.assertIn('QTEnhancedKey',s)
  # Settings shows 3-button UI with collecting state
  settings=(R/'Sources/QTSettings.m').read_text()
  self.assertIn('Enhanced logging',settings)
  self.assertIn('Collecting',settings)
  self.assertIn('Export logs',settings)
  self.assertIn('Clear logs',settings)
  # QTCore allows daily capture without separate inspectElements toggle
  core=(R/'Sources/QTCore.m').read_text()
  self.assertIn('|| QTDEnabled()',core)
  self.assertIn('1.2.0',core)
