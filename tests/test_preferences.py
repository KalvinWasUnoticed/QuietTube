"""Policy/source guards complement the macOS Foundation test of the real store helper."""
from pathlib import Path
import re,unittest
R=Path(__file__).resolve().parents[1]
class PreferenceTests(unittest.TestCase):
 def test_initializer_never_overwrites_present_values(self):
  s=(R/'Sources/QTPreferences.m').read_text()
  self.assertIn('if ([store objectForKey:full]==nil) [store setBool:',s)
  self.assertNotIn('removeObject',s)
  self.assertNotIn('registerDefaults:',s)
  self.assertIn('objectForKey:@"QuietTube.recovery02.initialized"]!=nil',s)
  self.assertIn('if ([store objectForKey:marker]==nil)',s)
 def test_fresh_vs_upgrade_presence_not_truthiness(self):
  s=(R/'Sources/QTPreferences.m').read_text()
  self.assertIn('initial[@"enabled"]=@(!existing)',s)
  self.assertIn('primary ? @(!existing)',s)
  self.assertIn('isEqualToString:@"adTest"',s)
  self.assertIn('isEqualToString:@"feedAds"',s)
  self.assertNotIn('boolForKey:',s)
 def test_no_runtime_error_writes_preferences(self):
  s=(R/'Sources/QTAdProfile.m').read_text()
  for forbidden in ['QTSet(', 'setBool:', 'setObject:', 'removeObjectForKey:', ' synchronize]']:
   self.assertNotIn(forbidden,s)
  self.assertIn('static atomic_bool QTAdTripped = false;',s)
  self.assertIn('atomic_exchange(&QTAdTripped,true)',s)
  self.assertIn('saved preferences unchanged',s)
 def test_only_explicit_controls_or_initializer_write_preferences(self):
  for p in (R/'Sources').glob('*.m'):
   if p.name not in ['QTCore.m','QTPreferences.m','QTMutationTrace.m','QTSettingsModel.m']:
    self.assertNotIn('QTSet(',p.read_text(),p.name)
    self.assertNotIn('setBool:',p.read_text(),p.name)
 def test_native_tests_and_build_are_wired(self):
  self.assertIn('Sources/QTPreferences.m',(R/'scripts/build.sh').read_text())
  self.assertIn('scripts/test_native.py',(R/'scripts/check.sh').read_text())
  self.assertIn('tests/test_preferences.m',(R/'scripts/test_native.py').read_text())
  s=(R/'tests/test_preferences.m').read_text()
  self.assertIn('bits<32',s);self.assertIn('launch<20',s)
  self.assertIn('initWithSuiteName:name',s)
 def test_defaults_and_status_are_explicit(self):
  core=(R/'Sources/QTCore.m').read_text()
  for key in ['adTest','feedAds']:
   section=core.split('@"key":@"'+key+'"')[1].split('},')[0]
   self.assertIn('@"default":@YES',section)
  ui=(R/'Sources/QTSettings.m').read_text()
  self.assertIn('QTAdProfilePaused()',ui)
  self.assertIn('Your saved choice is unchanged',ui)
