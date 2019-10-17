from .util import progress_move, progress_item
from pathlib import Path

import json
import os


CONFIG_DIRECTORY = Path("~").expanduser()


def config_dir(dir_name: str) -> Path:
    cfg_dir = CONFIG_DIRECTORY / ".config"
    owned_config_dir = cfg_dir / dir_name
    owned_config_dir.mkdir(exist_ok=True)
    return owned_config_dir


def install():
    cfg_dir = config_dir("dalloriam")  # TODO: Parametrize

    datahose_cfg_file = cfg_dir / "datahose.json"
    if datahose_cfg_file.exists():
        progress_item("Datahose is already configured!")
        return

    with open(os.path.join(cfg_dir, "datahose.json"), "a") as outfile:
        json.dump(
            {
                "service_host": input("Enter datahose service host: "),
                "email": input("Enter datahose account email: "),
                "password": input("Enter datahose password: "),
            },
            outfile,
        )


if __name__ == "__main__":
    install()
