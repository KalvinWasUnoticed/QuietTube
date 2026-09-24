"""Source-only checks: no claim to execute native Objective-C on this host."""
from pathlib import Path
import hashlib,json,re,unittest
R=Path(__file__).resolve().parents[1]
class PlayerProbeChecks(unittest.TestCase):
    def test_prior_baseline_unchanged_outside_probe_and_version(self):
        for name,expected in json.loads((R/'BASELINE-0.9.1.json').read_text()).items():
            with self.subTest(file=name):
                text=(R/name).read_text()
                text=re.sub(r'// BEGIN 0\.10 PLAYER PROBE\n.*?// END 0\.10 PLAYER PROBE\n','',text,flags=re.S)
                text=text.replace(' Sources/QTPlayerProbe.m','')
                text=text.replace('Playback test 0 — observation only','Mix playlist destination filtering')
                text=text.replace('0.10','VERSION').replace('0.9.1','VERSION')
                self.assertEqual(hashlib.sha256(text.encode()).hexdigest(),expected)
    def test_opt_in_and_master_gates(self):
        source=(R/'Sources/QTPlayerProbe.m').read_text()
        self.assertIn('if (!QTOn(@"enabled") || !QTOn(@"playerProbe")) return;',source)
        core=(R/'Sources/QTCore.m').read_text()
        start=core.index('@"key":@"playerProbe"')
        self.assertIn('@"default":@NO',core[start:core.index('},',start)])
        start=core.index('@"key":@"playerAds"')
        self.assertIn('@"disabled":@YES',core[start:core.index('},',start)])
    def test_one_original_call_and_same_result(self):
        s=(R/'Sources/QTPlayerProbe.m').read_text()
        body=s[s.index('return ^id(id object)'):]
        self.assertEqual(body.count('((id (*)(id,SEL))old)(object,sel)'),1)
        self.assertIn('return coordinator;',body)
        self.assertNotIn('return nil;',body)
        self.assertNotIn('@catch',body)
        self.assertNotIn('@try',body)
        self.assertIn('@"createAdsPlaybackCoordinator",@"@"',s)
    def test_no_request_response_or_private_data_handling(self):
        s=(R/'Sources/QTPlayerProbe.m').read_text()
        for prohibited in ['NSURLSession','NSURLRequest','playerAdsArray','adSlotsArray','spamSignals','description]', 'NSLog','videoId','HTTP','setValue:','seekTo','retry']:
            self.assertNotIn(prohibited,s)
        self.assertEqual(s.count('QTHook('),1)
        self.assertIn('Sources/QTPlayerProbe.m',(R/'scripts/build.sh').read_text())
    def test_diagnostics_report_actual_launch_mode(self):
        s=(R/'Sources/QTCore.m').read_text()
        self.assertIn('PLAYER TEST 0:',s)
        self.assertIn('QTOn(@"playerProbe") ? @"observation enabled" : @"off"',s)
