"""Patch-specific scope checks; these do not establish native runtime behavior."""
import hashlib,json,re,unittest
from pathlib import Path
R=Path(__file__).resolve().parents[1]
class PatchScopeTests(unittest.TestCase):
    def test_preserved_baseline_functions_and_modules(self):
        rec=json.loads((R/'BASELINE-0.13-CLEANUP.json').read_text())
        for file,expected in rec['files'].items():
            text=(R/file).read_text().replace('0.13.2','VERSION')
            self.assertEqual(hashlib.sha256(text.encode()).hexdigest(),expected,file)
        for item in rec['ranges']:
            text=(R/item['file']).read_text()
            part=text[text.index(item['start']):text.index(item['end']) if item['end'] else len(text)]
            self.assertEqual(hashlib.sha256(part.encode()).hexdigest(),item['sha256'],item['file'])
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
