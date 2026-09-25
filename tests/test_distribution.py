"""Source-distribution/integrity checks. No real GitHub service or Apple SDK."""
from pathlib import Path
import json, re, sys, tempfile, unittest
R=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(R/'scripts'))
import verify_release

class DistributionTests(unittest.TestCase):
 def test_manual_fork_build_and_acknowledgement(self):
  s=(R/'.github/workflows/build.yml').read_text()
  self.assertIn('workflow_dispatch:',s)
  self.assertIn('github.event.repository.fork == true && inputs.acknowledge_rights == true',s)
  self.assertIn('contents: write',s)
  self.assertIn('persist-credentials: false',s)
  self.assertIn('BASE_IPA_URL: ${{ inputs.base_ipa_url }}',s)
  self.assertNotIn('${{ inputs.base_ipa_url }}',s.split('run: python scripts/download_base.py')[1])
 def test_exact_packaging_handoff_and_no_artifact_upload(self):
  s=(R/'.github/workflows/build.yml').read_text()
  self.assertIn('artifacts/QuietTube.dylib "$IPA_PATH"',s)
  self.assertIn('test -s "$IPA_PATH"',s)
  self.assertIn('python scripts/publish.py',s)
  self.assertNotIn('actions/upload-artifact',s)
  self.assertIn('if: always()',s)
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
 def test_local_document_links_exist(self):
  for p in [R/'README.md',R/'CONTRIBUTING.md',*(R/'docs').glob('*.md')]:
   refs=re.findall(r'\]\(([^)]+)\)',p.read_text())+re.findall(r'(?:src|href)="([^"]+)"',p.read_text())
   for ref in refs:
    if '://' in ref or ref.startswith('#'):continue
    local=ref.split('#')[0]
    if local:self.assertTrue((p.parent/local).exists(),f'{p.name}: {local}')
 def test_version_is_consistent(self):
  v=(R/'VERSION').read_text().strip()
  self.assertEqual(v,'1.0.1')
  self.assertIn(v,(R/'Sources/QTSettings.m').read_text())
  self.assertIn(v,(R/'Sources/QTAdProfile.m').read_text())
  self.assertIn(v,(R/'scripts/package.py').read_text())
  self.assertNotIn('0.14.0-rc1',(R/'Sources/QTSettings.m').read_text())


 def test_installer_neutral_branding_with_honest_test_scope(self):
  banner=(R/'docs/assets/banner.svg').read_text()
  readme=(R/'README.md').read_text()
  settings=(R/'Sources/QTSettings.m').read_text()
  self.assertNotIn('MADE FOR LIVECONTAINER',banner)
  self.assertIn('other sideloading methods',readme.lower())
  self.assertIn('not a design requirement',readme)
  self.assertNotIn('fully stop and reopen the LiveContainer guest',settings)
  self.assertIn('LiveContainer 3.8.0',settings)
 def test_catbox_is_an_upload_option_not_a_bundled_base(self):
  guide=(R/'docs/INSTALL.md').read_text()
  self.assertIn('https://catbox.moe/',guide)
  self.assertIn('200 MB',guide)
  self.assertIn('base_ipa_url',guide)
  self.assertIn('acknowledge_rights',guide)
  self.assertIn('not a secret',guide)
  self.assertNotIn('catbox.moe',(R/'scripts/download_base.py').read_text())
