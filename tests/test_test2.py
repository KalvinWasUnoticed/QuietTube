from pathlib import Path
import json,re,unittest
R=Path(__file__).resolve().parents[1]
class Test2Checks(unittest.TestCase):
    def test_legacy_flags_cannot_activate(self):
        core=(R/'Sources/QTCore.m').read_text()
        sources='\n'.join(p.read_text() for p in (R/'Sources').glob('*'))
        for key in ['playerExperiment1','companionAds']:
            self.assertNotIn('@"key":@"'+key+'"',core)
            self.assertNotIn('QTOn(@"'+key+'")',sources)
        self.assertNotIn('@"loadWithModel:",',sources)
    def test_new_flags_off_and_independent(self):
        core=(R/'Sources/QTCore.m').read_text()
        for key in ['playerExperiment2','insertionAds2']:
            start=core.index('@"key":@"'+key+'"')
            self.assertIn('@"default":@NO',core[start:core.index('},',start)])
        self.assertNotIn('insertionAds2',(R/'Sources/QTPlayerTest2.m').read_text())
    def test_scoped_flag_and_native_factory(self):
        s=(R/'Sources/QTPlayerTest2.m').read_text()
        self.assertIn('config == QTNoOpConfig',s)
        self.assertIn('static _Thread_local __unsafe_unretained id QTNoOpConfig',s)
        self.assertIn('@finally',s)
        self.assertIn('QTNoOpConfig = previous;',s)
        self.assertEqual(s.count('((id (*)(id,SEL,id,id,id,id))old)(object,sel,overlay,delegate,parent,response)'),1)
        self.assertIn('return result;',s)
        self.assertNotIn('return nil;',s)
        self.assertNotIn('setUseNoOp',s)
        self.assertNotIn('playerAdsArray',s)
        self.assertNotIn('adSlotsArray',s)
        self.assertIn('Sources/QTPlayerTest2.m',(R/'scripts/build.sh').read_text())
    def test_static_hook_abis_match_binary(self):
        rec=json.loads((R/'BASE-PLAYER-ABI.json').read_text())
        byclass={c['class']:c['methods'] for c in rec['classes']}
        expected=[('YTRealAdsPlayerServices','adsPlaybackCoordinatorWithOverlayManager:delegate:parentResponder:contentPlayerResponse:','@@@@@'),('YTInnerTubeCollectionViewController','insertBelowVisibleSection:','v@')]
        for cls,name,sig in expected:
            entry=next(m for m in byclass[cls] if m['name']==name)
            normalized=re.sub(r'\d+','',entry['types']).replace('@:','',1)
            self.assertEqual(normalized,sig)
    def test_insertion_not_generic_or_multi_item_removal(self):
        s=(R/'Sources/QTFeatures.m').read_text()
        helper=s[s.index('static BOOL QTInsertionIsAd'):s.index('static void QTNoArgAction')]
        self.assertIn('[children count]==1',helper)
        for bad in ['id.sponsor_button','inline_injection_teaser','video_metadata','QTFeedShorts','QTFeedMix']:
            self.assertNotIn(bad,helper)
        self.assertIn('QTOn(@"insertionAds2") && QTOn(@"feedAds") && QTOn(@"extendedFeed")',s)
        self.assertIn('QTNodeBudget = savedBudget;',s)
