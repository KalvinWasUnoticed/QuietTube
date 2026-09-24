"""Static source regression checks, NOT Objective-C compilation/runtime tests."""
from pathlib import Path
import unittest
R=Path(__file__).resolve().parents[1]
class RevisionChecks(unittest.TestCase):
    def test_pip_control_and_hooks_removed(self):
        core=(R/'Sources/QTCore.m').read_text()
        features=(R/'Sources/QTFeatures.m').read_text()
        self.assertNotIn('@"key":@"pip"',core)
        self.assertNotIn('QTOn(@"pip")',features)
        self.assertNotIn('isPlayableInPictureInPicture',features)
        self.assertNotIn('enablePipForNonPremiumUsers',features)
    def test_no_reset_migration_added(self):
        core=(R/'Sources/QTCore.m').read_text()
        self.assertIn('QuietTube.recovery02.initialized',core)
        self.assertIn('QTActiveFlags = [active copy]',core)
        self.assertNotIn('recovery03',core)
    def test_navigation_is_owned_not_host_push(self):
        source=(R/'Sources/QTSettings.m').read_text()
        self.assertIn('initWithRootViewController:page',source)
        self.assertIn('UIModalPresentationPageSheet',source)
        self.assertIn('UIBarButtonSystemItemDone',source)
        self.assertNotIn('NSSelectorFromString(@"pushViewController:")',source)
    def test_no_old_model_or_layout_hooks(self):
        source=(R/'Sources/QTFeatures.m').read_text()
        self.assertNotIn('QTFilterGetter',source)
        self.assertNotIn('QTHook(@"YTIPlayerResponse"',source)
        self.assertNotIn('@"layoutSubviews"',source)
        self.assertIn('sections.count > 0 && filtered.count == 0',source)

class ExtendedFeedChecks(unittest.TestCase):
    def test_extended_feed_is_opt_in(self):
        core=(R/'Sources/QTCore.m').read_text()
        self.assertIn('@"key":@"extendedFeed", @"title":@"Extended feed formats", @"group":@"Distractions", @"default":@NO',core)
        features=(R/'Sources/QTFeatures.m').read_text()
        self.assertIn('if (!QTOn(@"extendedFeed")) return NO;',features)
        self.assertIn('QTNodeBudget = 1200;',features)
        self.assertNotIn('[node description]',features)
