import tempfile
import unittest
from pathlib import Path

import yaml

from scripts.update_image import update_image


class UpdateImageTests(unittest.TestCase):
    def test_published_digest_replaces_tag_and_preserves_resources(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "kustomization.yaml"
            path.write_text("resources: [deployment.yaml]\nimages:\n- name: backend\n  newTag: old\n")
            update_image(path, "docker.io/student/backend", "sha256:" + "a" * 64)
            document = yaml.safe_load(path.read_text())
        self.assertEqual(document["resources"], ["deployment.yaml"])
        self.assertEqual(document["images"], [{
            "name": "backend", "newName": "docker.io/student/backend", "digest": "sha256:" + "a" * 64,
        }])

    def test_invalid_publication_does_not_modify_gitops_state(self):
        for image, digest in [
            ("docker.io/student/backend", "latest"),
            ("docker.io/student/backend\ninjected: value", "sha256:" + "a" * 64),
        ]:
            with self.subTest(image=image, digest=digest), tempfile.TemporaryDirectory() as directory:
                path = Path(directory) / "kustomization.yaml"
                original = "images:\n- name: backend\n  newTag: old\n"
                path.write_text(original)
                with self.assertRaises(ValueError):
                    update_image(path, image, digest)
                self.assertEqual(path.read_text(), original)


if __name__ == "__main__":
    unittest.main()
