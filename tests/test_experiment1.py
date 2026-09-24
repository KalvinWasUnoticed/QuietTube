"""Retirement checks. Keep this filename to overwrite obsolete 0.11 tests on upload.

These checks deliberately require experiment 1 to be ABSENT. Do not restore
its failed nil-coordinator or broad model-load code to satisfy the old tests.
"""
from pathlib import Path
import unittest

R = Path(__file__).resolve().parents[1]

class RetiredExperiment1Checks(unittest.TestCase):
    def test_retired_flags_are_not_registered_or_read(self):
        core = (R / 'Sources/QTCore.m').read_text()
        sources = '\n'.join(p.read_text() for p in (R / 'Sources').glob('*.m'))
        for key in ['playerExperiment1', 'companionAds']:
            self.assertNotIn('@"key":@"' + key + '"', core)
            self.assertNotIn('QTOn(@"' + key + '")', sources)

    def test_coordinator_probe_does_not_suppress_creation(self):
        source = (R / 'Sources/QTPlayerProbe.m').read_text()
        self.assertNotIn('return nil;', source)
        self.assertNotIn('creation suppressed', source)
        self.assertEqual(source.count('((id (*)(id,SEL))old)(object,sel)'), 1)
        self.assertIn('return coordinator;', source)

    def test_broad_model_load_hook_stays_removed(self):
        source = (R / 'Sources/QTFeatures.m').read_text()
        self.assertNotIn('@"loadWithModel:",', source)
        self.assertNotIn('post-play model-load', source)
        self.assertIn('@"insertBelowVisibleSection:",@"v@"', source)

    def test_replacement_experiments_remain_opt_in(self):
        core = (R / 'Sources/QTCore.m').read_text()
        for key in ['playerExperiment2', 'insertionAds2']:
            start = core.index('@"key":@"' + key + '"')
            self.assertIn('@"default":@NO', core[start:core.index('},', start)])
