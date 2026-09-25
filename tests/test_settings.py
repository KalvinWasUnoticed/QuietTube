from pathlib import Path
import hashlib,json,re,unittest
from preservation import reviewed_source
R=Path(__file__).resolve().parents[1]
UI=(R/'Sources/QTSettings.m').read_text()
MODEL=(R/'Sources/QTSettingsModel.m').read_text()
class ReleaseUITests(unittest.TestCase):
 def test_runtime_frozen(self):
  for name,digest in json.loads((R/'tests/fixtures/preservation.json').read_text())['runtime'].items():
   self.assertEqual(hashlib.sha256(reviewed_source(name).replace('1.1.0','VERSION').encode()).hexdigest(),digest,name)
 def test_catalog_covers_existing_keys_once(self):
  keys=re.findall(r'@"key":@"(\w+)"',(R/'Sources/QTCore.m').read_text())
  catalog=re.findall(r'@\[@"(\w+)",@"(?:Ads|Feed|Playback|Appearance|Advanced|Troubleshooting)"',MODEL)
  self.assertEqual(sorted(keys),sorted(catalog))
  self.assertEqual(len(catalog),len(set(catalog)))
 def test_toggles_nonmodal_and_notice_coalesces(self):
  changed=UI.split('- (void)changed:')[1].split('- (void)applyPreset')[0]
  self.assertNotIn('UIAlert',changed)
  self.assertNotIn('presentViewController',changed)
  self.assertIn('noticeGeneration==generation',UI)
  self.assertIn('dispatch_get_main_queue()',UI)
  self.assertIn('QTSettingsPendingRestart()',UI)
 def test_restart_compares_raw_snapshot(self):
  body=(R/'Sources/QTCore.m').read_text().split('BOOL QTSettingsPendingRestart(void)')[1]
  self.assertIn('QTActiveFlags[key]',body)
  self.assertNotIn('QTOn(',body)
 def test_preview_does_not_apply_until_requested(self):
  preview=UI.split('if (self.preview) {')[1].split('} else if (!self.group)')[0]
  self.assertNotIn('QTSaveSettings(',preview)
  self.assertIn('QTSaveSettings(self.preview);',UI)
  self.assertIn('before==after',preview)
 def test_presets_do_not_change_playback_preferences(self):
  body=MODEL.split('NSDictionary<NSString *,NSNumber *> *QTPresetChanges')[1].split('void QTSaveSettings')[0]
  self.assertNotIn('@"background"',body); self.assertNotIn('@"autoplay"',body)
  self.assertIn('@"mutationTrace":@NO',body); self.assertIn('@"inspectElements":@NO',body)
  self.assertIn('return @{}',body)
 def test_writes_are_known_keys_and_no_live_installation(self):
  self.assertIn('[known containsObject:key]',MODEL)
  self.assertNotIn('QTInstall',MODEL)
  self.assertIn('Sources/QTSettingsModel.m',(R/'scripts/build.sh').read_text())
