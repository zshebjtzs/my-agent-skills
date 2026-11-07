import importlib.util
import os
import stat
import tempfile
import unittest
import zipfile
from pathlib import Path

MODULE_PATH = Path(__file__).with_name("validate-skill-zip.py")
SPEC = importlib.util.spec_from_file_location("validate_skill_zip", MODULE_PATH)
validator = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(validator)


class ValidateSkillZipTests(unittest.TestCase):
    def make_zip(self, entries):
        temp = tempfile.NamedTemporaryFile(suffix=".zip", delete=False)
        temp.close()
        with zipfile.ZipFile(temp.name, "w") as archive:
            for name, content, *attrs in entries:
                info = zipfile.ZipInfo(name)
                if attrs:
                    info.external_attr = attrs[0]
                archive.writestr(info, content)
        self.addCleanup(lambda: os.path.exists(temp.name) and os.unlink(temp.name))
        return temp.name

    def test_accepts_root_skill_with_nested_text_files(self):
        archive = self.make_zip([
            ("SKILL.md", "# Example skill\n"),
            ("references/guide.txt", "Reference text"),
            ("scripts/run.py", "print('stored, not executed')"),
        ])
        files = validator.read_zip(archive)
        self.assertEqual(files["SKILL.md"], "# Example skill\n")
        self.assertEqual(files["references/guide.txt"], "Reference text")
        self.assertEqual(files["scripts/run.py"], "print('stored, not executed')")

    def test_normalizes_single_top_level_folder(self):
        archive = self.make_zip([
            ("example-skill/SKILL.md", "# Example skill"),
            ("example-skill/references/guide.md", "Guide"),
        ])
        files = validator.read_zip(archive)
        self.assertIn("SKILL.md", files)
        self.assertIn("references/guide.md", files)
        self.assertNotIn("example-skill/SKILL.md", files)

    def test_rejects_path_traversal(self):
        archive = self.make_zip([
            ("SKILL.md", "# Example skill"),
            ("../outside.txt", "no"),
        ])
        with self.assertRaises(validator.ValidationError):
            validator.read_zip(archive)

    def test_rejects_symlink_entries(self):
        symlink_mode = (stat.S_IFLNK | 0o777) << 16
        archive = self.make_zip([
            ("SKILL.md", "# Example skill"),
            ("link.txt", "target", symlink_mode),
        ])
        with self.assertRaises(validator.ValidationError):
            validator.read_zip(archive)

    def test_rejects_case_conflicting_paths(self):
        archive = self.make_zip([
            ("SKILL.md", "# Example skill"),
            ("Notes.txt", "one"),
            ("notes.txt", "two"),
        ])
        with self.assertRaises(validator.ValidationError):
            validator.read_zip(archive)

    def test_rejects_multiple_skill_files(self):
        archive = self.make_zip([
            ("SKILL.md", "# Root"),
            ("nested/SKILL.md", "# Nested"),
        ])
        with self.assertRaises(validator.ValidationError):
            validator.read_zip(archive)

    def test_rejects_binary_content(self):
        archive = self.make_zip([
            ("SKILL.md", "# Example skill"),
            ("image.bin", b"\\x00\\x01"),
        ])
        with self.assertRaises(validator.ValidationError):
            validator.read_zip(archive)

    def test_rejects_invalid_utf8(self):
        archive = self.make_zip([
            ("SKILL.md", "# Example skill"),
            ("notes.txt", b"\\xff\\xfe"),
        ])
        with self.assertRaises(validator.ValidationError):
            validator.read_zip(archive)

    def test_rejects_file_over_per_file_limit(self):
        archive = self.make_zip([
            ("SKILL.md", "# Example skill"),
            ("large.txt", b"x" * (validator.MAX_FILE_BYTES + 1)),
        ])
        with self.assertRaises(validator.ValidationError):
            validator.read_zip(archive)


if __name__ == "__main__":
    unittest.main()
