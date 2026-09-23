import importlib.util
import io
from pathlib import Path
import struct
import tempfile
import unittest
import zipfile

spec=importlib.util.spec_from_file_location('package',Path(__file__).resolve().parents[1]/'scripts/package.py')
p=importlib.util.module_from_spec(spec)
spec.loader.exec_module(p)

def fixture(padding=True,cryptid=0):
    data=bytearray(2048)
    segment_size=72+80
    enc_size=24
    struct.pack_into('<8I',data,0,0xFEEDFACF,0x100000C,0,2,2,segment_size+enc_size,0,0)
    struct.pack_into('<II',data,32,0x19,segment_size)
    struct.pack_into('<QQ',data,32+40,0,len(data))
    struct.pack_into('<I',data,32+64,1)
    sec=32+72
    struct.pack_into('<Q',data,sec+40,512)
    struct.pack_into('<I',data,sec+48,1024 if padding else 32+segment_size+enc_size)
    struct.pack_into('<6I',data,32+segment_size,0x2C,24,1024,512,cryptid,0)
    return bytes(data)

class PackagingTests(unittest.TestCase):
    def test_injection(self):
        original=fixture()
        edited=p.inject(original)
        cmds,end=p.commands(edited)
        self.assertEqual(len(cmds),3)
        self.assertIn(p.DYLIB_PATH.encode(),edited)
        self.assertEqual(len(edited),len(original))
        self.assertEqual(edited[1024:],original[1024:])
    def test_duplicate_rejected(self):
        with self.assertRaises(ValueError): p.inject(p.inject(fixture()))
    def test_encrypted_rejected(self):
        with self.assertRaises(ValueError): p.inject(fixture(cryptid=1))
    def test_no_padding_rejected(self):
        with self.assertRaises(ValueError): p.inject(fixture(padding=False))
    def test_nonzero_padding_rejected(self):
        data=bytearray(fixture()); data[210]=1
        with self.assertRaises(ValueError): p.inject(data)
    def test_wrong_binary_rejected(self):
        with self.assertRaises(ValueError): p.inject(b'not a Mach-O')
    def test_traversal_rejected(self):
        buf=io.BytesIO()
        with zipfile.ZipFile(buf,'w') as z: z.writestr('../escape','bad')
        with tempfile.TemporaryDirectory() as td, zipfile.ZipFile(buf) as z:
            with self.assertRaises(ValueError): p.safe_extract(z,Path(td))
    def test_extract_valid(self):
        buf=io.BytesIO()
        with zipfile.ZipFile(buf,'w') as z: z.writestr('Payload/App.app/Info.plist','ok')
        with tempfile.TemporaryDirectory() as td, zipfile.ZipFile(buf) as z:
            p.safe_extract(z,Path(td))
            self.assertEqual((Path(td)/'Payload/App.app/Info.plist').read_text(),'ok')

if __name__=='__main__': unittest.main()
