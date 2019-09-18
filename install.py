from pathlib import Path

from subprocess import check_output
from dalloriam.system.path import location

import fire
import json
import shutil
import sys
import os

CONFIG_DIRECTORY = Path('~').expanduser()


def config_dir(dir_name: str) -> Path:
    cfg_dir = CONFIG_DIRECTORY / ".config"
    owned_config_dir = cfg_dir / dir_name
    owned_config_dir.mkdir(exist_ok=True)
    return owned_config_dir


class ToolingSetup:

    @staticmethod
    def _configure_datahose(cfg_dir: str) -> None:
        cfg_dir = config_dir(cfg_dir)

        datahose_cfg_file = cfg_dir / "datahose.json"
        if datahose_cfg_file.exists():
            print(' * Datahose is already configured!')
            return

        with open(os.path.join(cfg_dir, 'datahose.json'), 'a') as outfile:
            json.dump({
                'service_host': input('Enter datahose service host: '),
                'email': input('Enter datahose account email: '),
                'password': input('Enter datahose password: ')
            }, outfile)

    @staticmethod
    def configure(cfg_dir_name: str = 'dalloriam') -> None:
        print('[ Misc. Configuration ]')
        ToolingSetup._configure_datahose(cfg_dir_name)
        print()

    @staticmethod
    def _setup_fonts():
        if sys.platform == 'linux':
            font_dir = Path('~').expanduser() / '.local' / 'share' / 'fonts'
        elif sys.platform == 'darwin':
            font_dir = Path('~').expanduser() / 'Library' / 'Fonts'
        else:
            return

        print('[ Fonts Setup ]')
        abs_font_dir = Path('./fonts').absolute()

        for f in abs_font_dir.rglob('*'):
            if not f.is_dir() or f.name.startswith('.'):
                continue

            print(f'    * Installing {f.name.split(".")[0].title()}')
            dst_path = font_dir / f.name
            if dst_path.is_dir():
                shutil.rmtree(dst_path)
            shutil.copytree(f, dst_path)
        print()

    @staticmethod
    def config() -> None:
        """
        Setup symlinks for config entries.
        """
        print('[~/.config/ Setup]')
        src_dir = Path('./config').absolute()
        dst_config_dir = Path('~').expanduser() / '.config'

        for f in src_dir.rglob('*'):
            if f.is_dir():
                continue

            replaced_root = str(f).replace(str(src_dir), '')
            if replaced_root.startswith('/'):
                replaced_root = replaced_root[1:]
            dst_path = dst_config_dir / replaced_root
            dst_path.parent.mkdir(exist_ok=True, parents=True)

            print(f'    * {f} -> {dst_path}')
            if dst_path.is_symlink() or dst_path.is_file():
                dst_path.unlink()
            dst_path.symlink_to(f, target_is_directory=False)

        print()

    @staticmethod
    def dotfiles() -> None:
        """
        Setup symlinks for dotfiles, taking current platform into account.
        """

        print('[ Dotfiles Setup ]')
        dotfile_abs = Path('dotfiles').absolute()

        for f in dotfile_abs.rglob('*'):
            if f.name.startswith('.'):
                continue
            dest_path = Path('~').expanduser() / ('.' + f.name)
            print(f'    * {f} -> {dest_path}')

            if dest_path.exists() or dest_path.is_symlink():
                dest_path.unlink()

            dest_path.symlink_to(f, target_is_directory=False)

        print()

        ToolingSetup._setup_fonts()

    @staticmethod
    def scripts() -> None:
        print('[ Scripts Setup ]')
        scripts_abs = Path('./scripts').absolute()

        dest_dir = Path('~/bin').expanduser()
        dest_dir.mkdir(exist_ok=True)

        for script_full_path in scripts_abs.rglob('*'):
            tgt_name = script_full_path.name
            if '_' in script_full_path.name:
                if script_full_path.name.split('_')[0] != sys.platform:
                    print(f'    x Skipping {script_full_path.name} - wrong platform.')
                    continue
                tgt_name = script_full_path.name.split('_')[-1]

            dest_path = dest_dir / tgt_name
            print(f'    * {script_full_path} -> {dest_path}')
            if dest_path.exists() or dest_path.is_symlink():
                dest_path.unlink()
            dest_path.symlink_to(script_full_path, target_is_directory=False)

        print()

    @staticmethod
    def installers() -> None:
        print('[ Software Installation ]')
        installer_abs_dir = os.path.abspath('installers')

        for f in os.listdir(installer_abs_dir):
            installer_path = os.path.join(installer_abs_dir, f)
            if '_' in f:
                if f.split('_')[0] != sys.platform:
                    print(f'    x Skipping {installer_path} - wrong platform')
                    continue

            print(f' * {installer_path}')
            output = check_output([installer_path])
            if output:
                for out_line in output.split(b'\n'):
                    if out_line:
                        print(f'    - {out_line.decode()}')

            print()

    @staticmethod
    def repositories() -> None:
        print('[ Dependent Repositories ]')
        clone_file = Path('./clones.json')
        clone_data = json.loads(clone_file.read_text())

        for repository_url, platforms in clone_data.items():
            if sys.platform not in platforms:
                print(f'! Skipping [{repository_url}] -- Unsupported platform')
                continue

            target_directory = platforms[sys.platform]
            target_path = Path(target_directory).expanduser()

            if target_path.exists():
                print(f'* Repository [{target_path}] exists. Checking for updates...')
                with location(target_path):
                    check_output(['git', 'pull', 'origin', 'master'])


    @staticmethod
    def all(push: bool = False):
        ToolingSetup.configure()
        #ToolingSetup.dotfiles()
        ToolingSetup.config()
        ToolingSetup.scripts()
        #ToolingSetup.repositories()
        #ToolingSetup.installers()


if __name__ == '__main__':
    fire.Fire(ToolingSetup)
