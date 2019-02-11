from dalloriam import docker

from subprocess import check_output

import fire
import json
import shutil
import sys
import os


def link(src_file: str, dst_file: str):
    if os.path.isfile(dst_file) and os.path.islink(dst_file):
        os.remove(dst_file)

    os.symlink(src_file, dst_file, target_is_directory=False)


def link_dir(src_dir: str, dst_dir: str):
    if os.path.isdir(dst_dir) and os.path.islink(dst_dir):
        os.remove(dst_dir)

    os.symlink(src_dir, dst_dir, target_is_directory=True)


def config_dir(dir_name: str):
    cfg_dir = os.path.expanduser('~/.config')
    if not os.path.isdir(cfg_dir):
        os.mkdir(cfg_dir)

    owned_config_dir = os.path.join(cfg_dir, dir_name)
    if not os.path.isdir(owned_config_dir):
        os.mkdir(owned_config_dir)

    return owned_config_dir


class ToolingSetup:

    @staticmethod
    def _configure_datahose(cfg_dir: str) -> None:
        cfg_dir = config_dir(cfg_dir)

        datahose_cfg_file = os.path.join(cfg_dir, 'datahose.json')
        if os.path.isfile(datahose_cfg_file):
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
            font_dir = '~/.local/share/fonts'
        elif sys.platform == 'darwin':
            font_dir = '~/Library/Fonts'
        else:
            return

        print('[ Fonts Setup ]')
        abs_font_dir = os.path.abspath('./fonts')
        dst_dir = os.path.expanduser(font_dir)

        for f in os.listdir(abs_font_dir):
            src_path = os.path.join(abs_font_dir, f)
            if not os.path.isdir(src_path) or f.startswith('.'):
                continue

            print(f'    * Installing {f.split(".")[0].title()}')
            dst_path = os.path.join(dst_dir, f)
            if os.path.isdir(dst_path):
                shutil.rmtree(dst_path)
            shutil.copytree(src_path, dst_path)
        print()

    @staticmethod
    def config():
        print('[~/.config/ Setup]')
        src_dir = os.path.abspath('./config')
        dst_config_dir = os.path.expanduser('~/.config')

        for root, dirs, files in os.walk(src_dir):
            for f in files:
                tgt_path = os.path.join(root, f)

                replaced_root = root.replace(src_dir, '')
                if replaced_root.startswith('/'):
                    replaced_root = replaced_root[1:]
                dst_dir = os.path.join(dst_config_dir, replaced_root)
                if not os.path.isdir(dst_dir):
                    os.mkdir(dst_dir)
                dst_path = os.path.join(dst_dir, f)
                print(f'    * {tgt_path} -> {dst_path}')
                link(tgt_path, dst_path)
        print()

    @staticmethod
    def dotfiles() -> None:
        """
        Setup symlinks for dotfiles, taking current platform into account.
        """

        print('[ Dotfiles Setup ]')
        dotfiles_abs = os.path.abspath('dotfiles')

        for f in filter(lambda x: not x.startswith('.'), os.listdir(dotfiles_abs)):
            dotfile_full_path = os.path.join(dotfiles_abs, f)
            dest_path = os.path.expanduser(f'~/.{f}')
            print(f'    * {dotfile_full_path} -> {dest_path}')
            link(dotfile_full_path, dest_path)
        print()

        ToolingSetup._setup_fonts()

    @staticmethod
    def scripts() -> None:
        print('[ Scripts Setup ]')
        scripts_abs = os.path.abspath('scripts')

        dest_dir = os.path.expanduser('~/bin')
        if not os.path.isdir(dest_dir):
            os.mkdir(dest_dir)

        for f in os.listdir(scripts_abs):
            script_full_path = os.path.join(scripts_abs, f)

            if '_' in f:
                if f.split('_')[0] != sys.platform:
                    print(f'    x Skipping {script_full_path} - wrong platform.')
                    continue
                f = f.split('_')[-1]

            dest_path = os.path.join(dest_dir, f)
            print(f'    * {script_full_path} -> {dest_path}')
            link(script_full_path, dest_path)

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
    def all(push: bool = False):
        ToolingSetup.configure()
        ToolingSetup.dotfiles()
        ToolingSetup.config()
        ToolingSetup.scripts()
        ToolingSetup.installers()


if __name__ == '__main__':
    fire.Fire(ToolingSetup)
