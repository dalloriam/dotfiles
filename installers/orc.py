#!/usr/bin/env python
from typing import List

import os
import platform
import requests
import stat
import subprocess
import shutil
import sys

import urllib.request


GITHUB_RELEASES_PATTERN = "https://api.github.com/repos/{owner}/{repo}/releases/latest"
DST_DIR = os.path.expanduser('~/bin')
PLUGINS = [
    'github.com/dalloriam/orc/plugins/orc_local',
    'github.com/dalloriam/orc/plugins/datahose'
]

# TODO: Move this "install latest release from github" to stdlib?

def _get_latest_releases_artifact(owner: str, repo: str) -> List[str]:
    url = GITHUB_RELEASES_PATTERN.format(owner=owner, repo=repo)
    data = requests.get(url).json()

    expected_filename = f'orc-{sys.platform}-{platform.machine().replace("x86_64", "amd64")}'

    for asset in data['assets']:
        if asset['name'] == expected_filename:
            return asset['browser_download_url']
    
    raise ValueError(f"No such artifact: {expected_filename}")


def _fetch_artifact(artifact_url: str, dst_path: str) -> None:
    urllib.request.urlretrieve(artifact_url, filename=dst_path)
    st = os.stat(dst_path)
    os.chmod(dst_path, st.st_mode | stat.S_IEXEC)

def install(owner: str, repo: str) -> None:
    print(f'Installing/updating {owner}/{repo}...')
    try:
        url = _get_latest_releases_artifact(owner, repo)
        
        dst_path = os.path.join(DST_DIR, repo)
        _fetch_artifact(url, dst_path)

    except Exception as e:
        print(f'Stopping installation: {e}')


def plugins() -> None:
    print('Installing ORC plugins...')

    for plugin in PLUGINS:
        plugin_name = plugin.split('/')[-1]
        print(f'    - {plugin_name}')
        output = subprocess.check_output(['go', 'get', '-u', plugin])
        if output:
            print(output)
            return

        shutil.move(
            os.path.join(DST_DIR, plugin_name),
            os.path.expanduser(f'~/.config/dalloriam/orc/plugins/{plugin_name}')
        )



def main() -> None:
    install('dalloriam', 'orc')
    plugins()


if __name__ == '__main__':
    main()