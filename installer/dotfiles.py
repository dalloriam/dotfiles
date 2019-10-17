from .util import progress_item, progress_move

from pathlib import Path


_DOTFILE_SRC_DIR = Path("./dotfiles").absolute()
_HOME_DIR = Path("~").expanduser()


def install():
    for f in _DOTFILE_SRC_DIR.rglob("*"):
        if f.name.startswith("."):
            continue

        dest_path = _HOME_DIR / ("." + f.name)
        progress_move(f, dest_path)

        if dest_path.exists() or dest_path.is_symlink():
            dest_path.unlink()

        dest_path.symlink_to(f, target_is_directory=False)


if __name__ == "__main__":
    install()
