"""Replaces retired probe assertions under the same filename for safe uploads."""
from pathlib import Path
import unittest
R=Path(__file__).resolve().parents[1]
class RetiredProbeChecks(unittest.TestCase):
    def test_probe_not_built_or_activated(self):
        self.assertNotIn('Sources/QTPlayerProbe.m',(R/'scripts/build.sh').read_text())
        self.assertNotIn('QTInstallPlayerProbe',(R/'Sources/QTFeatures.m').read_text())
        self.assertNotIn('@"key":@"playerProbe"',(R/'Sources/QTCore.m').read_text())
    def test_only_current_ad_controls_registered(self):
        s=(R/'Sources/QTCore.m').read_text()
        for key in ['adTestPlayer','adTestFeed','playerAds','home','playerExperiment1','playerExperiment2','companionAds','insertionAds2']:
            self.assertNotIn('@"key":@"'+key+'"',s)
