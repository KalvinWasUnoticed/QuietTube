"""Offline shell integration tests; no real GitHub release is created."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
class ReleaseTests(unittest.TestCase):
    def invoke(self, private='true', approval='false', gh_fail=False, create_ipa=True):
        with tempfile.TemporaryDirectory() as t:
            root=Path(t); (root/'bin').mkdir(); (root/'artifacts').mkdir()
            if create_ipa: (root/'artifacts/QuietTube-0.13.5-21.38.2.ipa').write_bytes(b'fixture')
            gh=root/'bin/gh'
            gh.write_text('#!/usr/bin/env python3\nimport json,os,sys\nfrom pathlib import Path\nPath(os.environ["MOCK_CALL"]).write_text(json.dumps(sys.argv[1:]))\nsys.exit(int(os.environ["MOCK_FAIL"]))\n')
            gh.chmod(0o755)
            env=dict(os.environ, PATH=str(root/'bin')+os.pathsep+os.environ['PATH'],
                GITHUB_REPOSITORY='owner/personal-app', GITHUB_RUN_ID='123', GITHUB_RUN_ATTEMPT='2',
                GITHUB_SHA='abc123', GITHUB_STEP_SUMMARY=str(root/'summary.md'), GH_TOKEN='mock-not-real',
                REPO_PRIVATE=private, ALLOW_PUBLIC_RELEASE=approval, GITHUB_SERVER_URL='https://github.com',
                RUNNER_TEMP=str(root), MOCK_CALL=str(root/'call.json'), MOCK_FAIL='7' if gh_fail else '0')
            result=subprocess.run(['bash',str(ROOT/'scripts/release.sh')],cwd=root,env=env,capture_output=True,text=True)
            summary=(root/'summary.md').read_text() if (root/'summary.md').exists() else ''
            call=json.loads((root/'call.json').read_text()) if (root/'call.json').exists() else None
            return result,summary,call
    def test_private_direct_link_and_actual_ipa_argument(self):
        run,summary,call=self.invoke()
        self.assertEqual(run.returncode,0,run.stderr)
        self.assertIn('releases/download/quiettube-0.13.5-123-2/QuietTube-0.13.5-21.38.2.ipa',summary)
        self.assertIn('artifacts/QuietTube-0.13.5-21.38.2.ipa',call)
        self.assertFalse(any(a.endswith('.zip') for a in call))
        self.assertNotIn('mock-not-real',run.stdout+summary)
        self.assertIn('--prerelease',call)
    def test_public_requires_opt_in(self):
        run,summary,call=self.invoke(private='false')
        self.assertNotEqual(run.returncode,0); self.assertIsNone(call); self.assertEqual(summary,'')
    def test_public_explicit_approval(self):
        run,summary,call=self.invoke(private='false',approval='true')
        self.assertEqual(run.returncode,0); self.assertIn('DOWNLOAD IPA',summary)
    def test_failed_upload_no_success_link(self):
        run,summary,call=self.invoke(gh_fail=True)
        self.assertEqual(run.returncode,7); self.assertEqual(summary,'')
    def test_missing_ipa_never_published(self):
        run,summary,call=self.invoke(create_ipa=False)
        self.assertNotEqual(run.returncode,0); self.assertIsNone(call)
    def test_no_artifact_upload_in_workflow(self):
        workflow=(ROOT/'.github/workflows/build.yml').read_text()
        self.assertNotIn('actions/upload-artifact',workflow)
        self.assertIn('contents: write',workflow)
        self.assertIn('GITHUB_STEP_SUMMARY',workflow)
