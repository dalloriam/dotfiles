from .util import progress_move, progress_item
from pathlib import Path

import sys


def install():
    scripts_abs = Path("./scripts").absolute()

    dest_dir = Path("~/bin").expanduser()
    dest_dir.mkdir(exist_ok=True)

    for script_full_path in scripts_abs.rglob("*"):
        tgt_name = script_full_path.name
        if "_" in script_full_path.name:
            if script_full_path.name.split("_")[0] != sys.platform:
                progress_item(f"x Skipping {script_full_path.name} - wrong platform.")
                continue
            tgt_name = script_full_path.name.split("_")[-1]

        dest_path = dest_dir / tgt_name
        progress_move(script_full_path, dest_path)
        if dest_path.exists() or dest_path.is_symlink():
            dest_path.unlink()
        dest_path.symlink_to(script_full_path, target_is_directory=False)


if __name__ == "__main__":
    install()
