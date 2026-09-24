from pathlib import Path
import unittest
R=Path(__file__).resolve().parents[1]
class Experiment1Checks(unittest.TestCase):
    def test_new_flags_are_opt_in(self):
        core=(R/'Sources/QTCore.m').read_text()
        for key in ['playerExperiment1','companionAds']:
            start=core.index('@"key":@"'+key+'"')
            self.assertIn('@"default":@NO',core[start:core.index('},',start)])
    def test_suppression_does_not_construct_then_discard(self):
        s=(R/'Sources/QTPlayerProbe.m').read_text()
        branch=s[s.index('if (QTOn(@"playerExperiment1"))'):s.index('QTProbeCount(@"player probe coordinator call entered")')]
        self.assertIn('return nil;',branch)
        self.assertNotIn('old)',branch)
        self.assertEqual(s.count('QTHook('),1)
        self.assertEqual(s.count('((id (*)(id,SEL))old)(object,sel)'),1)
    def test_model_boundary_gated_and_fail_open(self):
        s=(R/'Sources/QTFeatures.m').read_text()
        self.assertIn('QTOn(@"companionAds") && QTOn(@"feedAds") && QTOn(@"extendedFeed")',s)
        self.assertIn('@"loadWithModel:",@"v@"',s)
        self.assertIn('if (candidate) filtered = candidate;',s)
        self.assertIn('hasPrefix:@"YTI"',s)
        self.assertIn('((void (*)(id,SEL,id))old)(object,sel,filtered);',s)
        self.assertIn('empty model-load result prevented',s)
    def test_player_and_feed_experiments_independent(self):
        player=(R/'Sources/QTPlayerProbe.m').read_text()
        self.assertNotIn('companionAds',player)
        features=(R/'Sources/QTFeatures.m').read_text()
        self.assertNotIn('playerExperiment1',features)
