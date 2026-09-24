"""Patch-specific scope checks; these do not establish native runtime behavior."""
import hashlib,json,re,unittest
from pathlib import Path
R=Path(__file__).resolve().parents[1]
class PatchScopeTests(unittest.TestCase):
    def test_prior_implementation_preserved_except_version_and_feature(self):
        baseline=json.loads((R/'BASELINE-0.9.json').read_text())
        for name,expected in baseline.items():
            with self.subTest(file=name):
                text=(R/name).read_text()
                text=re.sub(r'// BEGIN 0\.9\.1 WATCH AGAIN\n.*?// END 0\.9\.1 WATCH AGAIN\n','',text,flags=re.S)
                text=text.replace(', QTFeedWatchAgain = 1024','')
                text=text.replace(' || QTOn(@"watchAgain")','')
                text=text.replace(',@"watchAgain"]',']')
                text=text.replace('0.9.1','VERSION')
                self.assertEqual(hashlib.sha256(text.encode()).hexdigest(),expected)
    def test_independent_opt_in_and_dependency(self):
        core=(R/'Sources/QTCore.m').read_text()
        start=core.index('@"key":@"watchAgain"')
        self.assertIn('@"default":@NO',core[start:core.index('},',start)])
        source=(R/'Sources/QTFeatures.m').read_text()
        self.assertIn('(kind & QTFeedWatchAgain) && QTOn(@"watchAgain")',source)
        self.assertIn('QTOn(@"mixes") || QTOn(@"watchAgain")',source)
        self.assertLess(source.index('if (!QTOn(@"extendedFeed")) return NO;'),source.index('if (QTOn(@"watchAgain"))'))
        self.assertIn('@"mixes",@"watchAgain"]',(R/'Sources/QTSettings.m').read_text())
    def test_native_title_is_shelf_only(self):
        s=(R/'Sources/QTFeatures.m').read_text()
        helper=s[s.index('static NSString *QTShelfTitle'):s.index('static BOOL QTDropNode')]
        self.assertIn('hasSuffix:@"ShelfRenderer"',helper)
        self.assertIn('hasPrefix:@"YTI"',helper)
        self.assertIn('QTShelfTitle(node)',s[s.index('if (QTOn(@"watchAgain"))'):s.index('if (QTOn(@"topicsShelves"))')])
