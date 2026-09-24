import json, re, unittest
from pathlib import Path
R=Path(__file__).resolve().parents[1]
S=(R/'Sources/QTMutationTrace.m').read_text()
class MinimizeTraceTests(unittest.TestCase):
 def test_binary_methods(self):
  evidence=json.loads((R/'BASE-MINIMIZE-ABI.json').read_text())
  methods=[m for c in evidence['classes'] for m in c['methods']]
  self.assertEqual(len(methods),9)
  for m in methods:self.assertIn(m['name'],S)
  self.assertIn('@"@@^"',S)
  self.assertIn('strcmp([sig getArgumentTypeAtIndex:3],"^@")',S)
 def test_passthrough(self):
  self.assertIn('return ((id(*)(id,SEL,id,NSError *__autoreleasing *))old)(obj,sel,operation,error);',S)
  self.assertIn('old)(obj,sel,entries,indexes)',S)
  self.assertNotIn('objc_msgSend',S)
  self.assertNotIn('QTGet(',S)
  self.assertNotIn('@catch',S[S.index('void QTInstallMutationTrace'):S.index('NSString *QTMutationReport')])
 def test_bounds_and_privacy(self):
  for token in ['QTTraceCollapse?96:24','now-QTTraceCollapse>12.0','MIN(a.count,(NSUInteger)3)','QTTraceOutside++','QTTraceDropped++']:self.assertIn(token,S)
  for token in ['description]','userInfo','absoluteString','NSData','setValue:']:self.assertNotIn(token,S)
 def test_prepare_only_changes_prerequisites(self):
  body=S.split('void QTPrepareAdTest(void) {')[1].split('\n}')[0]
  self.assertIn('QTSet(key, YES)',body)
  self.assertNotIn('QTInstall',body)
  self.assertNotIn('removeAllObjects',body)
  self.assertIn('QTTestFlags()',body)
  for flag in ['enabled','adTest','feedAds','extendedFeed','displayAds','inspectElements','mutationTrace']:self.assertIn('@"'+flag+'"',S)
 def test_wired_and_opt_in(self):
  self.assertIn('Sources/QTMutationTrace.m',(R/'scripts/build.sh').read_text())
  self.assertIn('QTInstallMutationTrace();',(R/'Sources/QTFeatures.m').read_text())
  self.assertIn('QTMutationReport()',(R/'Sources/QTAdProfile.m').read_text())
  self.assertIn('QTPrepareAdTest();',(R/'Sources/QTSettings.m').read_text())
  self.assertIn('if (!QTOn(@"enabled") || !QTOn(@"mutationTrace")) return;',S)
