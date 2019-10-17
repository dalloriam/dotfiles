from .util import progress_move
from pathlib import Path


_CONFIG_SOURCE = Path("./config").absolute()
_CONFIG_DEST = Path("~").expanduser() / ".config"


def install() -> None:
    for f in _CONFIG_SOURCE.rglob("*"):
        if f.is_dir():
            continue

        replaced_root = str(f).replace(str(_CONFIG_SOURCE), "")
        if replaced_root.startswith("/"):
            replaced_root = replaced_root[1:]
        dst_path = _CONFIG_DEST / replaced_root
        dst_path.parent.mkdir(exist_ok=True, parents=True)

        progress_move(f, dst_path)
        if dst_path.is_symlink() or dst_path.is_file():
            dst_path.unlink()
        dst_path.symlink_to(f, target_is_directory=False)


if __name__ == "__main__":
    install()
