from dalloriam import docker

import fire
import json
import sys
import os


def link(src_file: str, dst_file: str):
    if os.path.isfile(dst_file) and os.path.islink(dst_file):
        os.remove(dst_file)

    os.symlink(src_file, dst_file, target_is_directory=False)


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
                'password': input('Enter datahose password: ')
            }, outfile)

    @staticmethod
    def configure(cfg_dir_name: str = 'dalloriam') -> None:
        print('[ Misc. Configuration ]')
        ToolingSetup._configure_datahose(cfg_dir_name)
        print()

    @staticmethod
    def _build_docker_image(build_path: str, image: str, tag: str = 'latest'):
        print(f'        * Building image [{image}].')
        docker.Client().build(content_dir=build_path, image_name=image, tag=tag)
        print(f'        * Image [{image}] built successfully.')

    @staticmethod
    def dotfiles() -> None:
        """
        Setup symlinks for dotfiles, taking current platform into account.
        """

        print('[ Dotfiles Setup ]')
        dotfiles_abs = os.path.abspath('dotfiles')
        for f in os.listdir(dotfiles_abs):
            dotfile_full_path = os.path.join(dotfiles_abs, f)
            dest_path = os.path.expanduser(f'~/.{f}')
            print(f'    * {dotfile_full_path} -> {dest_path}')
            link(dotfile_full_path, dest_path)

        print()

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
    def tools(prefix: str = 'dalloriam', tool_dir: str = None) -> None:
        print('[ Docker-based Tools Preparation ]')
        if tool_dir is None:
            tool_dir = './tools'

        tool_dir = os.path.abspath(tool_dir)

        for folder in os.listdir(tool_dir):
            if not os.path.isdir(os.path.join(tool_dir, folder)):
                continue

            has_dockerfile = any(fname == 'Dockerfile' for fname in os.listdir(os.path.join(tool_dir, folder)))

            if has_dockerfile:
                image = f'{prefix}/{folder}'
                build_path = os.path.join(tool_dir, folder)

                print(f'    * {image}:latest')
                ToolingSetup._build_docker_image(build_path, image)

                docker.Client().push(image)

    @staticmethod
    def all():
        ToolingSetup.configure()
        ToolingSetup.dotfiles()
        ToolingSetup.scripts()
        ToolingSetup.tools()


if __name__ == '__main__':
    fire.Fire(ToolingSetup)