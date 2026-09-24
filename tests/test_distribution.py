"""Source-distribution/integrity checks. No real GitHub service or Apple SDK."""
from pathlib import Path
import json, re, sys, tempfile, unittest
R=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(R/'scripts'))
import verify_release
import build_info

class DistributionTests(unittest.TestCase):
 def test_manual_library_only_workflow(self):
  s=(R/'.github/workflows/build.yml').read_text()
  self.assertIn('workflow_dispatch:',s)
  self.assertIn('contents: read',s)
  self.assertIn('bash scripts/build.sh',s)
  self.assertIn('artifacts/QuietTube.dylib',s)
  self.assertNotIn('contents: write',s)
  for forbidden in ['curl ', 'wget ', 'python scripts/package.py','gh release','allow_public_release','IPA_PATH','pull_request_target']:
   self.assertNotIn(forbidden,s)
 def test_artifact_is_allowlisted_not_directory(self):
  s=(R/'.github/workflows/build.yml').read_text()
  self.assertIn('artifacts/BUILD-INFO.json',s)
  self.assertIn('artifacts/SHA256SUMS',s)
  self.assertNotIn('artifacts/*',s)
  self.assertNotIn('path: artifacts',s)
  self.assertIn('retention-days: 7',s)
  self.assertIn('artifact-url',s)
 def test_actions_are_commit_pinned(self):
  for file in (R/'.github/workflows').glob('*.yml'):
   for ref in re.findall(r'uses:\s*(\S+)',file.read_text()):
    self.assertRegex(ref,r'^actions/[a-z-]+@[0-9a-f]{40}$')
 def test_no_old_publisher_or_hosted_base(self):
  self.assertFalse((R/'scripts/release.sh').exists())
  for folder in ['scripts','.github','docs']:
   for p in (R/folder).rglob('*'):
    if p.is_file() and p.suffix in ['.py','.sh','.yml','.md']:
     self.assertNotIn('files.catbox.moe',p.read_text(),str(p))
 def test_manifest_matches(self):
  manifest=json.loads((R/'release-manifest.json').read_text())
  self.assertEqual(verify_release.verify(R,manifest),[])
  for name in ['Sources/QTSettings.m','Sources/QTSettingsModel.m','scripts/package.py','.github/workflows/build.yml','VERSION']:
   self.assertIn(name,manifest['sha256'])
 def test_manifest_rejects_mixed_and_missing(self):
  with tempfile.TemporaryDirectory() as t:
   root=Path(t);(root/'x').write_text('old code')
   record={'release':'test','sha256':{'x':'bad','y':'bad'},'forbidden_legacy_files':[]}
   self.assertEqual(len(verify_release.verify(root,record)),2)
 def test_manifest_rejects_retired_publisher(self):
  with tempfile.TemporaryDirectory() as t:
   root=Path(t);(root/'obsolete').write_text('')
   record={'release':'test','sha256':{},'forbidden_legacy_files':['obsolete']}
   self.assertIn('obsolete file',verify_release.verify(root,record)[0])
 def test_build_info_rejects_nonlibrary(self):
  with tempfile.TemporaryDirectory() as t:
   p=Path(t)/'lib';p.write_bytes(b'not Mach-O')
   with self.assertRaises(ValueError):build_info.describe(p,'1.0.0','commit')
 def test_local_document_links_exist(self):
  for p in [R/'README.md',R/'CONTRIBUTING.md',*(R/'docs').glob('*.md')]:
   refs=re.findall(r'\]\(([^)]+)\)',p.read_text())+re.findall(r'(?:src|href)="([^"]+)"',p.read_text())
   for ref in refs:
    if '://' in ref or ref.startswith('#'):continue
    local=ref.split('#')[0]
    if local:self.assertTrue((p.parent/local).exists(),f'{p.name}: {local}')
 def test_version_is_consistent(self):
  v=(R/'VERSION').read_text().strip()
  self.assertEqual(v,'1.0.0')
  self.assertIn(v,(R/'Sources/QTSettings.m').read_text())
  self.assertIn(v,(R/'Sources/QTAdProfile.m').read_text())
  self.assertIn(v,(R/'scripts/package.py').read_text())
  self.assertNotIn('0.14.0-rc1',(R/'Sources/QTSettings.m').read_text())

 def test_build_info_describes_library_without_an_app(self):
  import struct
  from test_package import fixture
  with tempfile.TemporaryDirectory() as t:
   p=Path(t)/'QuietTube.dylib'
   data=bytearray(fixture()); struct.pack_into('<I',data,12,6); p.write_bytes(data)
   info=build_info.describe(p,'1.0.0','source-commit')
   self.assertEqual(info['source_commit'],'source-commit')
   self.assertEqual(info['quiettube'],'1.0.0')
   self.assertEqual(info['architecture'],'arm64')
   self.assertEqual(len(info['library_sha256']),64)
