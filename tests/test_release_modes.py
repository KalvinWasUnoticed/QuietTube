"""Synthetic files and mocked gh: publishing modes, exact assets and failure safety."""
import hashlib,json,os,subprocess,sys,tempfile,unittest
from pathlib import Path
import test_fork_pipeline as pipeline
R=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(R/'scripts'))
import publish
class ReleaseModeTests(unittest.TestCase):
 def tree(self,t):return pipeline.PublishTests().setup_tree(t)
 def test_ipa_has_separate_dylib_link_and_both_hashes(self):
  with tempfile.TemporaryDirectory() as t:
   root,ipa,env=self.tree(t);calls=[]
   publish.publish(env,root,lambda args,**kw:calls.append(args))
   lib=root/'artifacts/QuietTube.dylib'
   self.assertIn(str(ipa),calls[0]);self.assertIn(str(lib),calls[0])
   summary=(root/'summary').read_text()
   self.assertIn('DOWNLOAD IPA',summary);self.assertIn('DOWNLOAD DYLIB',summary)
   record=json.loads((root/'artifacts/BUILD-INFO.json').read_text())
   self.assertEqual(record['dylib_sha256'],hashlib.sha256(lib.read_bytes()).hexdigest())
   self.assertEqual(record['release_kind'],'ipa');self.assertTrue(record['prerelease'])
   self.assertIn('do not inject',summary.lower())
 def test_dylib_upstream_or_fork_regular_or_prerelease(self):
  for upstream in [True,False]:
   for prerelease in ['true','false']:
    with self.subTest(upstream=upstream,prerelease=prerelease),tempfile.TemporaryDirectory() as t:
     root,ipa,env=self.tree(t);ipa.unlink()
     env.update(RELEASE_KIND='dylib',PRERELEASE=prerelease,IS_FORK='false' if upstream else 'true',GITHUB_REPOSITORY='KalvinWasUnoticed/QuietTube' if upstream else 'tester/QuietTube')
     calls=[];url=publish.publish(env,root,lambda args,**kw:calls.append(args))
     self.assertTrue(url.endswith('/QuietTube.dylib'))
     self.assertIn('quiettube-dylib-',url)
     self.assertEqual('--prerelease' in calls[0],prerelease=='true')
     self.assertIn('--draft',calls[0]);self.assertIn('--draft=false',calls[1])
     self.assertFalse(any(arg.endswith('.ipa') for arg in calls[0]))
     self.assertNotIn('DOWNLOAD IPA',(root/'summary').read_text())
     record=json.loads((root/'artifacts/BUILD-INFO.json').read_text())
     self.assertNotIn('ipa_sha256',record);self.assertEqual(record['release_kind'],'dylib')
 def test_dylib_does_not_upload_leftover_ipa_or_unrelated_files(self):
  with tempfile.TemporaryDirectory() as t:
   root,ipa,env=self.tree(t);env.update(RELEASE_KIND='dylib')
   extra=root/'artifacts/private.txt';extra.write_text('not for upload')
   calls=[];publish.publish(env,root,lambda args,**kw:calls.append(args))
   self.assertNotIn(str(ipa),calls[0]);self.assertNotIn(str(extra),calls[0])
   self.assertIn(str(root/'artifacts/QuietTube-NOTICES.txt'),calls[0])
 def test_checksums_cover_binaries_notices_and_metadata(self):
  for kind in ['ipa','dylib']:
   with tempfile.TemporaryDirectory() as t:
    root,ipa,env=self.tree(t);env['RELEASE_KIND']=kind
    publish.publish(env,root,lambda *a,**kw:None)
    lines=(root/'artifacts/SHA256SUMS').read_text().splitlines()
    self.assertEqual(len(lines),4 if kind=='ipa' else 3)
    for line in lines:
     digest,name=line.split('  ')
     self.assertEqual(hashlib.sha256((root/'artifacts'/name).read_bytes()).hexdigest(),digest)
 def test_invalid_mode_and_library_choices_fail_before_upload(self):
  for key,value in [('RELEASE_KIND','all'),('PRERELEASE','yes'),('ACKNOWLEDGE_RIGHTS','false'),('GITHUB_REPOSITORY','another/nonfork')]:
   with tempfile.TemporaryDirectory() as t:
    root,ipa,env=self.tree(t);env.update(RELEASE_KIND='dylib',IS_FORK='false',GITHUB_REPOSITORY='KalvinWasUnoticed/QuietTube');env[key]=value
    with self.assertRaises(ValueError):publish.publish(env,root,lambda *a,**k:self.fail('must not upload'))
    self.assertFalse((root/'summary').exists())
 def test_bad_or_missing_dylib_rejects_both_modes(self):
  for kind in ['ipa','dylib']:
   for bad in [None,b'',b'not a library',b'\0'*32]:
    with tempfile.TemporaryDirectory() as t:
     root,ipa,env=self.tree(t);env['RELEASE_KIND']=kind;lib=root/'artifacts/QuietTube.dylib'
     if bad is None:lib.unlink()
     else:lib.write_bytes(bad)
     with self.assertRaises(ValueError):publish.publish(env,root,lambda *a,**k:self.fail('must not upload'))
 def test_missing_license_rejects_before_upload(self):
  with tempfile.TemporaryDirectory() as t:
   root,ipa,env=self.tree(t);(root/'LICENSE').unlink()
   with self.assertRaises(ValueError):publish.publish(env,root,lambda *a,**k:self.fail('must not upload'))
 def test_dylib_failed_create_or_publish_does_not_claim_success(self):
  for stage in [1,2]:
   with tempfile.TemporaryDirectory() as t:
    root,ipa,env=self.tree(t);env['RELEASE_KIND']='dylib';calls=[]
    def run(args,**kw):
     calls.append(args)
     if len(calls)==stage:raise subprocess.CalledProcessError(7,args)
    with self.assertRaises(subprocess.CalledProcessError):publish.publish(env,root,run)
    self.assertFalse((root/'summary').exists())
 def test_dylib_workflow_has_no_base_download_or_package_step(self):
  s=(R/'.github/workflows/dylib.yml').read_text()
  for forbidden in ['base_ipa_url','download_base.py','package.py','IPA_PATH','actions/upload-artifact']:
   self.assertNotIn(forbidden,s)
  for required in ['workflow_dispatch:','macos-15','bash scripts/check.sh','bash scripts/build.sh','RELEASE_KIND: dylib','PRERELEASE: ${{ inputs.prerelease }}','default: true','KalvinWasUnoticed/QuietTube','if: always()']:
   self.assertIn(required,s)
  ipa=(R/'.github/workflows/build.yml').read_text()
  self.assertIn('github.event.repository.fork == true && inputs.acknowledge_rights == true',ipa)
  self.assertIn('RELEASE_KIND: ipa',ipa)
 def test_real_dylib_cli_with_mock_gh(self):
  with tempfile.TemporaryDirectory() as t:
   root,ipa,env=self.tree(t);ipa.unlink();(root/'scripts').mkdir();(root/'bin').mkdir()
   (root/'scripts/publish.py').write_bytes((R/'scripts/publish.py').read_bytes())
   gh=root/'bin/gh';gh.write_text('#!/usr/bin/env python3\nimport sys\nassert "--repo" in sys.argv\n');gh.chmod(0o755)
   env.update(PATH=str(root/'bin')+os.pathsep+os.environ['PATH'],RELEASE_KIND='dylib',PRERELEASE='false',IS_FORK='false',GITHUB_REPOSITORY='KalvinWasUnoticed/QuietTube')
   result=subprocess.run([sys.executable,str(root/'scripts/publish.py')],env=env,capture_output=True,text=True)
   self.assertEqual(result.returncode,0,result.stderr)
   self.assertIn('DOWNLOAD DYLIB',(root/'summary').read_text())
