"""Additional negative/input, interface inventory and CI coverage checks."""
from pathlib import Path
import hashlib,json,random,re,struct,sys,unittest
R=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(R/'scripts'))
import package,test_native
from test_package import fixture

class AuditTests(unittest.TestCase):
 def test_all_runtime_modules_are_compiled_once(self):
  built=re.findall(r'Sources/[A-Za-z]+\.m',(R/'scripts/build.sh').read_text())
  self.assertEqual(sorted(built),sorted(str(p.relative_to(R)) for p in (R/'Sources').glob('*.m')))
  self.assertEqual(len(built),len(set(built)))
 def test_apple_checks_run_before_base_download(self):
  workflow=(R/'.github/workflows/build.yml').read_text()
  self.assertLess(workflow.index('bash scripts/check.sh'),workflow.index('bash scripts/build.sh'))
  self.assertLess(workflow.index('bash scripts/build.sh'),workflow.index('python scripts/download_base.py'))
  checks=(R/'.github/workflows/checks.yml').read_text()
  self.assertIn('macos-15',checks);self.assertIn('ubuntu-latest',checks)
  self.assertIn('bash scripts/build.sh',checks)
 def test_foundation_model_does_not_depend_on_uikit(self):
  h=(R/'Sources/QTSettingsModel.h').read_text()
  self.assertNotIn('QTCore.h',h)
  self.assertIn('QTPreferences.h',h)
  self.assertIn('#import "QTCore.h"',(R/'Sources/QTSettings.m').read_text())
 def test_native_schema_covers_all_real_flags(self):
  options=test_native.declared_options()
  self.assertEqual(len(options),16)
  self.assertEqual({x['key'] for x in options if x['default']},{'adTest','feedAds','plainLogo'})
  ui=(R/'Sources/QTSettingsModel.m').read_text()
  keys=re.findall(r'@\[@"(\w+)",@"(?:Ads|Feed|Playback|Appearance|Advanced|Troubleshooting)"',ui)
  self.assertEqual(sorted(keys),sorted(o['key'] for o in options))
 def test_new_native_and_stress_tests_are_wired(self):
  script=(R/'scripts/test_native.py').read_text()
  for file in ['test_preferences.m','test_preferences_process.m','test_settings_native.m']:
   self.assertIn(file,script)
  self.assertIn('tests/test_stress.c',(R/'scripts/check.sh').read_text())
 def test_all_active_test_sources_are_manifested(self):
  names=json.loads((R/'release-manifest.json').read_text())['sha256']
  for folder in ['Sources','tests','scripts','.github/workflows']:
   for p in (R/folder).rglob('*'):
    if p.suffix in ['.m','.h','.c','.py','.sh','.yml','.json']:
     self.assertIn(str(p.relative_to(R)),names)
 def test_executable_type_rejected(self):
  data=bytearray(fixture());struct.pack_into('<I',data,12,6)
  with self.assertRaisesRegex(ValueError,'MH_EXECUTE'):package.inject(data)
 def test_truncated_known_commands_rejected(self):
  for cmd in [0x21,0x2C,0xC,0x80000018,0x8000001F,0x19]:
   with self.subTest(command=cmd):
    data=bytearray(512)
    struct.pack_into('<8I',data,0,0xFEEDFACF,0x100000C,0,2,1,8,0,0)
    struct.pack_into('<II',data,32,cmd,8)
    with self.assertRaisesRegex(ValueError,'Truncated'):package.inject(data)
 def test_dylib_path_bounds_rejected(self):
  for offset in [0,8,23,32,0xFFFFFFFF]:
   data=bytearray(512)
   struct.pack_into('<8I',data,0,0xFEEDFACF,0x100000C,0,2,1,32,0,0)
   struct.pack_into('<6I',data,32,0xC,32,offset,0,0,0)
   with self.assertRaisesRegex(ValueError,'path offset'):package.inject(data)
  data[56:64]=b'nonulxxx';struct.pack_into('<I',data,40,24)
  with self.assertRaisesRegex(ValueError,'terminator'):package.inject(data)
 def test_5000_macho_header_mutations_fail_closed_or_preserve_content(self):
  rng=random.Random(102);original=fixture()
  for _ in range(5000):
   data=bytearray(original)
   for _ in range(rng.randrange(1,5)):
    data[rng.randrange(208)]^=rng.randrange(1,256)
   before=bytes(data)
   try:result=package.inject(data)
   except ValueError:continue
   self.assertEqual(bytes(data),before)
   self.assertEqual(result[1024:],before[1024:])
   self.assertEqual(len(result),len(before))
   package.commands(result)
 def test_c_family_delimiters_balanced(self):
  # Cheap early guard for errors like the missing Objective-C ] in 1.0.1.
  # Not a compiler, type checker or substitute for the Apple SDK CI job.
  literals=re.compile(r'//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'',re.S)
  for folder in ['Sources','tests']:
   for p in (R/folder).iterdir():
    if p.suffix not in ['.m','.h','.c']:continue
    code=literals.sub('',p.read_text()); stack=[]
    for char in code:
     if char in '([{':stack.append(char)
     elif char in ')]}':
      self.assertTrue(stack,str(p))
      self.assertEqual(stack.pop(),{')':'(',']':'[','}':'{'}[char],str(p))
    self.assertEqual(stack,[],str(p))
