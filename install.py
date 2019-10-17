import installer
import sys


def run(module_name: str) -> None:
    getattr(installer, module_name).install()


def main():
    for tgt in sys.argv[1:]:
        run(tgt)


if __name__ == "__main__":
    main()
