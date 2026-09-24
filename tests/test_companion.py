from pathlib import Path
import hashlib,json,re,unittest
R=Path(__file__).resolve().parents[1]
class CompanionChecks(unittest.TestCase):
    def test_successful_player_path_unchanged(self):
        record=json.loads((R/'PLAYER-PATH-BASELINE.json').read_text())
        s=(R/'Sources/QTAdProfile.m').read_text()
        self.assertEqual(hashlib.sha256(s[s.index(record['start']):].encode()).hexdigest(),record['sha256'])
    def test_callback_signature_matches_binary(self):
        rec=json.loads((R/'BASE-COMPANION-ABI.json').read_text())
        m=next(m for m in rec['methods'] if m['name']=='companionAdDidChange:interactionLoggingAdsClientData:')
        self.assertEqual(re.sub(r'\d+','',m['types']).replace('@:','',1),'v@@')
        self.assertEqual(rec['class'],'YTCompanionAdObserverBehavior')
    def test_unused_companion_hook_retired(self):
        s=(R/'Sources/QTAdProfile.m').read_text()
        self.assertNotIn('YTCompanionAdObserverBehavior',s)
        self.assertNotIn('companionAdDidChange:',s)
        self.assertNotIn('enableWatchWhileFeedMutationOnIos',s)
        self.assertIn('QTInstallFeedInsertion()',s)
    def test_c_status_strings_are_ascii(self):
        (R/'Sources/QTAdState.h').read_bytes().decode('ascii')
