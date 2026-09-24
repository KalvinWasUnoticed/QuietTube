from pathlib import Path
import importlib.util, json, tempfile, unittest
R=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('verify_release',R/'scripts/verify_release.py')
module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
class ManifestTests(unittest.TestCase):
 def test_complete_sources_match(self):
  record=json.loads((R/'RELEASE-SOURCE-MANIFEST.json').read_text())
  self.assertEqual(module.verify(R,record),[])
  for name in ['Sources/QTSettings.m','Sources/QTSettingsModel.m','Sources/QTSettingsModel.h','scripts/build.sh','scripts/package.py','scripts/release.sh']:
   self.assertIn(name,record['sha256'])
 def test_missing_ui_rejected(self):
  with tempfile.TemporaryDirectory() as temp:
   record={'release':'test','sha256':{'Sources/QTSettingsModel.m':'unused'}}
   self.assertEqual(module.verify(Path(temp),record),['Sources/QTSettingsModel.m: missing'])
 def test_old_source_rejected(self):
  with tempfile.TemporaryDirectory() as temp:
   root=Path(temp); (root/'Sources').mkdir()
   (root/'Sources/QTSettings.m').write_text('old 0.13.5 UI')
   record=json.loads((R/'RELEASE-SOURCE-MANIFEST.json').read_text())
   subset={'release':record['release'],'sha256':{'Sources/QTSettings.m':record['sha256']['Sources/QTSettings.m']}}
   self.assertIn('does not match',module.verify(root,subset)[0])
 def test_build_guard_precedes_compile(self):
  s=(R/'.github/workflows/build.yml').read_text()
  self.assertLess(s.index('python scripts/verify_release.py'),s.index('bash scripts/build.sh'))
