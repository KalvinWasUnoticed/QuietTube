from pathlib import Path
import json,unittest
R=Path(__file__).resolve().parents[1]
class AdProfileTests(unittest.TestCase):
    def test_single_opt_in_and_retired_activation(self):
        core=(R/'Sources/QTCore.m').read_text()
        start=core.index('@"key":@"adTest"')
        self.assertIn('@"default":@NO',core[start:core.index('},',start)])
        for k in ['playerExperiment1','companionAds','playerExperiment2','insertionAds2']:
            self.assertNotIn('@"key":@"'+k+'"',core)
    def test_native_constructor_uses_verified_scope(self):
        s=(R/'Sources/QTAdProfile.m').read_text()
        self.assertIn('object_getIvar(object,scopeIvar)',s)
        self.assertIn('initWithServiceRegistryScope:scope delegate:delegate',s)
        self.assertIn('@protocol QTNativeNoOpInitializer',s)
        self.assertNotIn('QTNoOpConfig',s)
        self.assertNotIn('useNoOpAdsCoordinator',s)
        self.assertNotIn('return nil;',s)
        self.assertIn('old)(object,selector,overlay,delegate,parent,response)',s)
    def test_noop_and_feed_abi_records(self):
        record=json.loads((R/'BASE-AD-PROFILE-ABI.json').read_text())
        factory=next(c for c in record['surfaces'] if c['class']=='YTRealAdsPlayerServices')
        self.assertTrue(any(v['name']=='_serviceRegistryScope' and v['type'].startswith('@') for v in factory['ivars']))
        init=next(m for m in record['no_op']['methods'] if m['name']=='initWithServiceRegistryScope:delegate:')
        self.assertEqual(init['types'],'@32@0:8@16@24')
        methods=next(c for c in record['flags'] if c['class']=='YTHotConfig')['methods']
        self.assertTrue(methods)
        self.assertTrue(all(m['types']=='B16@0:8' for m in methods))
    def test_retry_installation_is_idempotent(self):
        s=(R/'Sources/QTAdProfile.m').read_text()
        self.assertIn('!QTPlayerProfileInstalled',s)
        self.assertIn('!QTFeedProfileInstalled',s)
        self.assertEqual(s.count('QTHook('),2)
    def test_error_latch_and_native_error_forwarding(self):
        s=(R/'Sources/QTAdProfile.m').read_text()
        self.assertIn('atomic_exchange(&QTAdTripped,true)',s)
        self.assertIn('QTSet(@"adTest",NO)',s)
        self.assertIn('!atomic_load(&QTAdTripped)',s)
        features=(R/'Sources/QTFeatures.m').read_text()
        self.assertIn('QTAdPlaybackError(error);',features)
        self.assertIn('((void (*)(id,SEL,id))old)(object,sel,error);',features)
        self.assertNotIn('seekTo',s)
    def test_report_bounded_and_no_raw_payload_logging(self):
        s=(R/'Sources/QTAdProfile.m').read_text()
        self.assertIn('QTAdEvents.count>=80',s)
        self.assertIn('depth<3',s)
        for banned in ['localizedDescription','absoluteString','HTTPBody','NSLog','[response description]','[error description]']:
            self.assertNotIn(banned,s)
        self.assertIn('Ad test report',(R/'Sources/QTSettings.m').read_text())

    def test_no_subordinate_flags_can_disable_profile(self):
        s=(R/'Sources/QTAdProfile.m').read_text()
        for key in ['adTestPlayer','adTestFeed','playerProbe']:
            self.assertNotIn('QTOn(@"'+key+'")',s)
        self.assertIn('if (!QTAdActive()) return;',s)
        self.assertIn('if (!QTPlayerProfileInstalled)',s)
        self.assertIn('if (!QTFeedProfileInstalled)',s)
    def test_report_distinguishes_installation_from_invocation(self):
        s=(R/'Sources/QTAdProfile.m').read_text()
        self.assertNotIn('Effective now:',s)
        self.assertIn('QTAdState(',s)
        self.assertIn('PLAYER BLOCKING NOT DEMONSTRATED',s)
        self.assertIn('FEED WORKAROUND NOT OBSERVED',s)
