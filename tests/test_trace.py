import json, re, unittest
from pathlib import Path
R=Path(__file__).resolve().parents[1]
S=(R/'Sources/QTMutationTrace.m').read_text()
class MinimizeTraceTests(unittest.TestCase):
 def test_binary_methods(self):
  evidence=json.loads((R/'tests/fixtures/native-abi.json').read_text())['trace']
  methods=[m for c in evidence['classes'] for m in c['methods']]
  self.assertEqual(len(methods),9)
  for m in methods:self.assertIn(m['name'],S)
  self.assertIn('@"@@^"',S)
  self.assertIn('strcmp([sig getArgumentTypeAtIndex:3],"^@")',S)
 def test_passthrough(self):
  self.assertIn('return ((id(*)(id,SEL,id,NSError *__autoreleasing *))old)(obj,sel,operation,error);',S)
  self.assertIn('old)(obj,sel,entries,indexes)',S)
  self.assertNotIn('objc_msgSend',S)
  self.assertNotIn('@catch',S[S.index('void QTInstallMutationTrace'):S.index('NSString *QTMutationReport')])
 def test_bounds_and_privacy(self):
  for token in ['QTTraceCollapse?96:24','now-QTTraceCollapse>12.0','MIN(a.count,(NSUInteger)3)','QTTraceOutside++','QTTraceDropped++']:self.assertIn(token,S)
  for token in ['description]','userInfo','absoluteString','setValue:']:self.assertNotIn(token,S)
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

 def test_insert_detail_is_bounded_and_not_a_filter(self):
  for token in ['QTTraceElementSamples>=6','length>262144','char names[8][97]','QTExtractTemplateNames','QTClassifyElementBytes','slot==8 && QTTraceCollapse>0']:
   self.assertIn(token,S)
  self.assertIn('isEqualToString:@"YTIElementRenderer"',S)
  self.assertNotIn('QTFiltered',S)
  self.assertNotIn('setElementData:',S)
  self.assertNotIn('removeObjects',S)
 def test_completion_fallback_and_correct_label(self):
  self.assertIn('slot==1 && (!QTTraceCollapse || now-QTTraceCollapse>12.0)',S)
  self.assertIn('QTTraceCompletionAnchor=(slot==1)',S)
  self.assertIn('collapse completion (start not observed in this window)',S)
  self.assertNotIn('Collapse start observed:',S)
 def test_all_installer_signatures_match_normalized_binary(self):
  evidence=json.loads((R/'tests/fixtures/native-abi.json').read_text())['trace']
  for c in evidence['classes']:
   for m in c['methods']:
    tokens=re.findall(r'\^?[@:vqiQBi]',m['types'])
    normalize=lambda t: 'Q' if t in ('q','Q') else 'B' if t in ('c','B') else '^' if t.startswith('^') else t
    compact=''.join(map(normalize,[tokens[0]]+tokens[3:]))
    if m['name'].endswith('error:'):
     self.assertEqual(compact,'@@^')
     self.assertIn('QTTraceNames()[slot],@"'+compact+'"',S)
    else:
     self.assertIn('@"'+m['name']+'",@"'+compact+'"',S)
