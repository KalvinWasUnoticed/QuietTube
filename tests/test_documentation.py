"""Copy/artwork guards only. No native runtime baselines are changed."""
from pathlib import Path
import re,struct,unittest,xml.etree.ElementTree as ET
R=Path(__file__).resolve().parents[1]
class DocumentationTests(unittest.TestCase):
 def test_prose_style_check(self):
  words='delve moreover furthermore robust seamless leverage utilize harness unlock elevate streamline cutting-edge state-of-the-art comprehensive holistic journey landscape realm tapestry testament underscore notably arguably resonate beacon cornerstone synergy transformative empowering impactful authentic resilient transcend reimagine redefine'.split()
  paths=[R/'README.md',R/'CONTRIBUTING.md',R/'CHANGELOG.md',R/'Notices/REFERENCES.md',*sorted((R/'docs').glob('*.md'))]
  for p in paths:
   text=p.read_text()
   for word in words:
    self.assertIsNone(re.search(r'(?<![\w-])'+re.escape(word)+r'(?![\w-])',text,re.I),f'{p.name}: {word}')
 def test_flat_artwork_palette_and_no_external_resources(self):
  for name in ['banner','mark']:
   root=ET.parse(R/f'docs/assets/{name}.svg').getroot()
   fills=set()
   for element in root.iter():
    self.assertNotIn(element.tag.split('}')[-1],['linearGradient','radialGradient','filter','image','script'])
    if 'fill' in element.attrib:fills.add(element.attrib['fill'])
   self.assertEqual(fills,{'#F1EBDD','#20201E','#C64936'})
   data=(R/f'docs/assets/{name}.png').read_bytes()
   self.assertEqual(data[:8],b'\x89PNG\r\n\x1a\n')
   self.assertEqual(struct.unpack('>II',data[16:24]),(1280,400) if name=='banner' else (192,192))
 def test_readme_explains_both_artifacts_and_playback_limit(self):
  text=(R/'README.md').read_text()
  for phrase in ['Build QuietTube dylib only','Build QuietTube IPA','not an App Attest or PO-token fix','AI help']:
   self.assertIn(phrase,text)
  self.assertIn('RC1',text)
  self.assertIn('docs/assets/banner.svg',text)
