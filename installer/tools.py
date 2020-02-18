from pathlib import Path
from subprocess import check_output
from typing import List

_BINMAN_PACKAGES_FILE = Path("./data") / "binman_packages.txt"


def get_installed_packages() -> List[str]:
    # TODO: Replace once binman supports structured output.
    return list(
        x.split("@")[0]
        for x in map(
            lambda x: x.split(" ")[-1].strip(),
            filter(bool, check_output(["binman", "list"]).decode("utf-8").split("\n")),
        )
    )


def install_pkg(package_name: str):
    x = check_output(["binman", "install", package_name]).decode("utf-8")
    print(x)


def _install_binman_packages():
    installed_packages = get_installed_packages()
    packages = _BINMAN_PACKAGES_FILE.read_text().split("\n")

    for package in filter(lambda x: bool(x) and x not in installed_packages, packages):
        install_pkg(package)


def install() -> None:
    _install_binman_packages()
