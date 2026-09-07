"""Record a successfully published image in the desired Kubernetes state."""

import argparse
import re
from pathlib import Path

import yaml


def update_image(path: Path, image: str, digest: str):
    if not re.fullmatch(r"docker\.io/[a-z0-9][a-z0-9_-]*/[a-z0-9][a-z0-9_.-]*", image):
        raise ValueError("Expected docker.io/<username>/<repository> in lowercase")
    if not re.fullmatch(r"sha256:[a-f0-9]{64}", digest):
        raise ValueError("Expected a sha256 digest returned by the Docker build")

    document = yaml.safe_load(path.read_text())
    images = [entry for entry in document.get("images", []) if entry.get("name") == "backend"]
    if len(images) != 1:
        raise ValueError("Kustomization must contain exactly one backend image")
    images[0].update(newName=image, digest=digest)
    images[0].pop("newTag", None)
    path.write_text(yaml.safe_dump(document, sort_keys=False))


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("image")
    parser.add_argument("digest")
    parser.add_argument("--file", type=Path, default=Path("k8s/kustomization.yaml"))
    args = parser.parse_args()
    update_image(args.file, args.image, args.digest)
