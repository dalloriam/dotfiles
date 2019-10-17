from .util import progress_item
from pathlib import Path

import shutil
import sys


def install() -> None:
    if sys.platform == "linux":
        font_dir = Path("~").expanduser() / ".local" / "share" / "fonts"
    elif sys.platform == "darwin":
        font_dir = Path("~").expanduser() / "Library" / "Fonts"
    else:
        print("Error: Unknown font directory.")
        return

    abs_font_dir = Path("./fonts").absolute()

    for f in abs_font_dir.rglob("*"):
        if not f.is_dir() or f.name.startswith("."):
            continue

        progress_item(f'Font {f.name.split(".")[0].title()}')
        dst_path = font_dir / f.name
        if dst_path.is_dir():
            shutil.rmtree(dst_path)
        shutil.copytree(f, dst_path)


if __name__ == "__main__":
    install()
