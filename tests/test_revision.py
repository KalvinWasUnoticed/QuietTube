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

class CaptureChecks(unittest.TestCase):
    def test_capture_is_bounded_opt_in_and_nonblocking(self):
        core=(R/'Sources/QTCore.m').read_text()
        self.assertIn('@"key":@"inspectElements", @"title":@"Inspect unmatched templates", @"group":@"Advanced", @"default":@NO',core)
        self.assertIn('QTElementsInspected>=128',core)
        self.assertIn('QTElementGroups.count>=48',core)
        features=(R/'Sources/QTFeatures.m').read_text()
        self.assertIn('QTObserveUnmatchedElement(data);',features)
        drop=features[features.index('static BOOL QTDropNode'):features.index('static id QTFilteredNode')]
        self.assertNotIn('QTOn(@"inspectElements")',drop)

class V06AuditChecks(unittest.TestCase):
    def test_new_filters_independent_and_off_by_default(self):
        core=(R/'Sources/QTCore.m').read_text()
        for key in ['topicsShelves','edgeCards']:
            start=core.index('@"key":@"'+key+'"')
            self.assertIn('@"default":@NO',core[start:core.index('},',start)])
        features=(R/'Sources/QTFeatures.m').read_text()
        self.assertIn('(kind & QTFeedTopics) && QTOn(@"topicsShelves")',features)
        self.assertIn('(kind & QTFeedEdgeVideo) && QTOn(@"edgeCards")',features)
    def test_logo_hooks_are_scoped(self):
        source=(R/'Sources/QTLogo.m').read_text()
        self.assertIn('if (!QTOn(@"plainLogo")) return;',source)
        self.assertIn('@"YTHeaderLogoControllerImpl"',source)
        self.assertNotIn('QTHook(@"UIImageView"',source)
        self.assertNotIn('QTHook(@"UIView"',source)
        self.assertNotIn('@"layoutSubviews"',source)
        self.assertIn('Sources/QTLogo.m',(R/'scripts/build.sh').read_text())
    def test_no_general_video_title_match(self):
        features=(R/'Sources/QTFeatures.m').read_text()
        self.assertIn('hasSuffix:@"ShelfRenderer"',features)
        self.assertIn('isEqualToString:@"explore more topics"',features)
        self.assertNotIn('containsString:@"Explore more topics"',features)
    def test_native_pip_authentication_and_error_behavior_unchanged(self):
        source=(R/'Sources/QTFeatures.m').read_text()
        self.assertNotIn('QTOn(@"pip")',source)
        self.assertNotIn('NSURLSession',source)
        self.assertNotIn('spamSignals',source)
        self.assertNotIn('TapToRetry',source)
        self.assertIn('((void (*)(id,SEL,id))old)(object,sel,error);',source)
    def test_settings_dependencies_and_restart_snapshot(self):
        ui=(R/'Sources/QTSettings.m').read_text()
        self.assertIn('dependencyReady',ui)
        self.assertIn('[self.tableView reloadData]',ui)
        core=(R/'Sources/QTCore.m').read_text()
        body=core[core.index('BOOL QTOn('):core.index('void QTSet(')]
        self.assertIn('QTActiveFlags',body)
        self.assertNotIn('NSUserDefaults',body)
    def test_logo_hook_signatures_match_inspected_metadata(self):
        import json,re
        record=json.loads((R/'BASE-LOGO-ABI.json').read_text())
        self.assertEqual(record['method_owner'],'YTHeaderLogoControllerImpl')
        signatures={m['name']:re.sub(r'\d+','',m['types']).replace('@:','',1) for m in record['methods']}
        source=(R/'Sources/QTLogo.m').read_text()
        hooks=re.findall(r'QTHook\(@"YTHeaderLogoControllerImpl",@"([^"]+)",@"([^"]+)"',source)
        self.assertEqual(len(hooks),2)
        for name,sig in hooks: self.assertEqual(signatures[name],sig)
        self.assertEqual(signatures['updateToDefaultLogo'],'v')
        self.assertEqual(signatures['defaultLogoImage'],'@')

class V07HotfixChecks(unittest.TestCase):
    def test_logo_default_pipeline_not_rescaled(self):
        source=(R/'Sources/QTLogo.m').read_text()
        self.assertNotIn('updateLogoWithImage:',source)
        self.assertNotIn('needsRescaling',source)
        self.assertNotIn('UIGraphicsImageRenderer',source)
        self.assertNotIn('defaultLogoImage',source)
        self.assertIn('NSSelectorFromString(@"updateToDefaultLogo")',source)
        self.assertIn('QTLogoResetting',source)
    def test_display_ad_extension_requires_both_flags(self):
        features=(R/'Sources/QTFeatures.m').read_text()
        self.assertIn('(kind & QTFeedDisplayAd) && QTOn(@"feedAds") && QTOn(@"displayAds")',features)
        core=(R/'Sources/QTCore.m').read_text()
        start=core.index('@"key":@"displayAds"')
        self.assertIn('@"default":@NO',core[start:core.index('},',start)])

class V08Checks(unittest.TestCase):
    def test_independent_mix_control(self):
        core=(R/'Sources/QTCore.m').read_text()
        start=core.index('@"key":@"mixes"')
        self.assertIn('@"default":@NO',core[start:core.index('},',start)])
        source=(R/'Sources/QTFeatures.m').read_text()
        self.assertIn('(kind & QTFeedMix) && QTOn(@"mixes")',source)
        self.assertIn('(kind & QTFeedInlineShort) && QTOn(@"edgeCards")',source)
        self.assertNotIn('containsString:@"Mix',source)
        self.assertIn('QTOn(@"inspectElements") || QTOn(@"mixes")',source)
    def test_no_generic_home_or_nudge_removal(self):
        source=(R/'Sources/QTFeedRules.h').read_text()
        self.assertNotIn('"home_vertical_feed_prominence_group_key"',source)
        self.assertNotIn('"inline_injection_teaser"',source)
        self.assertNotIn('"feed_nudge"',source)
