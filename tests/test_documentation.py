"""README edits must not masquerade as source-integrity failures."""
from pathlib import Path
import json, shutil, struct, sys, tempfile, unittest
import xml.etree.ElementTree as ET
R = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(R / 'scripts'))
import verify_release

class DocumentationTests(unittest.TestCase):
 def test_readme_is_not_checksum_locked(self):
  manifest = json.loads((R / 'release-manifest.json').read_text())
  self.assertNotIn('README.md', manifest['sha256'])
  for folder in ['Sources', 'scripts', '.github/workflows']:
   for path in (R / folder).rglob('*'):
    if path.is_file() and '__pycache__' not in path.parts and path.suffix != '.pyc':
     self.assertIn(path.relative_to(R).as_posix(), manifest['sha256'])

 def test_flat_artwork_palette_and_no_external_resources(self):
  for name in ['banner', 'mark']:
   root = ET.parse(R / f'docs/assets/{name}.svg').getroot()
   fills = set()
   for element in root.iter():
    self.assertNotIn(element.tag.split('}')[-1], ['linearGradient', 'radialGradient', 'filter', 'image', 'script'])
    if 'fill' in element.attrib:
     fills.add(element.attrib['fill'])
   self.assertEqual(fills, {'#F1EBDD', '#20201E', '#C64936'})
   data = (R / f'docs/assets/{name}.png').read_bytes()
   self.assertEqual(data[:8], b'\x89PNG\r\n\x1a\n')
   self.assertEqual(struct.unpack('>II', data[16:24]), (1280, 400) if name == 'banner' else (192, 192))

 def test_readme_edits_pass_but_runtime_edits_still_fail_integrity(self):
  manifest = json.loads((R / 'release-manifest.json').read_text())
  with tempfile.TemporaryDirectory() as temp:
   root = Path(temp)
   shutil.copytree(R, root, dirs_exist_ok=True,
                   ignore=shutil.ignore_patterns('__pycache__', '*.pyc', '.git', 'artifacts'))
   (root / 'README.md').write_text('# QuietTube\n\nEdited freely by the maintainer.\n')
   self.assertEqual(verify_release.verify(root, manifest), [])
   source = root / 'Sources/QTAdProfile.m'
   source.write_bytes(source.read_bytes() + b'\n/* simulated unintended source change */\n')
   failures = verify_release.verify(root, manifest)
   self.assertEqual(len(failures), 1)
   self.assertIn('Sources/QTAdProfile.m: does not match release', failures[0])
