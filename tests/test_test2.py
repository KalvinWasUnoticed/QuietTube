"""Replacement for retired 0.12 tests: retained filename for overlay uploads."""
from pathlib import Path
import unittest
R=Path(__file__).resolve().parents[1]
class RetiredTest2Checks(unittest.TestCase):
    def test_old_controls_not_registered(self):
        s=(R/'Sources/QTCore.m').read_text()
        for key in ['playerExperiment2','insertionAds2']:
            self.assertNotIn('@"key":@"'+key+'"',s)
    def test_old_module_not_compiled(self):
        self.assertNotIn('Sources/QTPlayerTest2.m',(R/'scripts/build.sh').read_text())
        self.assertNotIn('QTInstallPlayerTest2();',(R/'Sources/QTFeatures.m').read_text())
