from pathlib import Path
import json, unittest
R=Path(__file__).resolve().parents[1]
S=(R/'Sources/QTFeedInsertion.m').read_text()
class FeedInsertionTests(unittest.TestCase):
 def test_verified_boundary_signatures(self):
  record=json.loads((R/'tests/fixtures/native-abi.json').read_text())['insertion']
  for name,typ,compact in [('handleInsertItemSectionContent:error:','@32@0:8@16^@24','@@^'),('insertEntries:atIndex:','v32@0:8@16Q24','v@Q')]:
   self.assertTrue(any(m['name']==name and m['types']==typ for c in record['surfaces'] for m in c['methods']))
   self.assertIn('"'+typ+'"',S)
   self.assertIn('@"'+compact+'"',S)
 def test_scope_is_thread_local_and_restored_without_swallowing(self):
  self.assertIn('_Thread_local NSUInteger QTFeedScopeDepth',S)
  self.assertIn('QTFeedScopeDepth=active?previous+1:0;',S)
  self.assertIn('[object isKindOfClass:app]',S)
  self.assertIn('@finally',S)
  self.assertIn('QTFeedScopeDepth=previous;',S)
  install=S[S.index('BOOL QTInstallFeedInsertion'):S.index('NSString *QTFeedInsertionReport')]
  self.assertNotIn('@catch',install)
  self.assertEqual(install.count('old)(object,selector,operation,error)'),1)
  self.assertEqual(install.count('old)(object,selector,forwarded,index)'),1)
 def test_exact_marker_only_and_no_payload_guessing(self):
  self.assertIn('isEqualToString:@"YTIElementRenderer"',S)
  self.assertIn('QTBool(QTGet(entry,@"compatibilityOptions"),@"hasAdLoggingData")',S)
  for forbidden in ['inline_injection_teaser','home_vertical','elementData','QTClassifyElementBytes','containsString:','clearEntries','setContentsArray:']:
   self.assertNotIn(forbidden,S)
 def test_bounded_copy_and_fail_open(self):
  self.assertIn('QTInsertionBatchWithinLimit(array.count)',S)
  self.assertIn('if (!rejected) return entries;',S)
  self.assertIn('id result=[kept copy];',S)
  self.assertIn('else [kept addObject:entry];',S)
  self.assertIn('@catch',S)
  self.assertNotIn('[entries remove',S)
  self.assertNotIn('[array remove',S)
 def test_gates_and_installer_retry(self):
  self.assertIn('QTInsertionMayFilter(QTAdProfileActive(),QTOn(@"feedAds"),QTFeedScopeDepth)',S)
  self.assertIn('!QTFeedHandlerInstalled &&',S)
  self.assertIn('!QTFeedArrayInstalled &&',S)
  self.assertIn('return QTFeedHandlerInstalled && QTFeedArrayInstalled;',S)
 def test_shared_trace_ownership(self):
  trace=(R/'Sources/QTMutationTrace.m').read_text()
  self.assertIn('slot==5 && QTFeedInsertionHandlerInstalled()',trace)
  self.assertIn('QTTraceFeedInsertion(object,operation);',S)
  self.assertIn('QTTraceRecord(5,receiver,operation',trace)
 def test_completed_counter_follows_original_call(self):
  self.assertLess(S.index('old)(object,selector,forwarded,index)'),S.index('QTFeedAdd(QTFeedCompletedBatches,1)'))
  self.assertIn('FEED BLOCKING NOT DEMONSTRATED',S)
  self.assertIn('QTFeedTotals[8]',S)
 def test_build_and_player_baseline_wired(self):
  self.assertIn('Sources/QTFeedInsertion.m',(R/'scripts/build.sh').read_text())
  self.assertIn('QTFeedInsertionReport()',(R/'Sources/QTAdProfile.m').read_text())
