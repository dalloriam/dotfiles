""" Sets up everything. Requires python3.6+ """
from dalloriam import docker

import fire
import os


class Main:

    @staticmethod
    def _build_docker_image(build_path: str, image: str, tag: str = 'latest'):
        print(f'    * Building image [{image}].')
        docker.build(
            build_path=build_path,
            image_name=image
        )
        print(f'    * Image [{image}] built successfully.')

    @staticmethod
    def all(prefix: str = 'dalloriam') -> None:
        current_dir = os.path.abspath(os.getcwd())

        for folder in os.listdir(current_dir):
            if not os.path.isdir(os.path.join(current_dir, folder)):
                continue

            has_dockerfile = any(fname == 'Dockerfile' for fname in os.listdir(os.path.join(current_dir, folder)))

            if has_dockerfile:
                image = f'{prefix}/{folder}'
                build_path = os.path.join(current_dir, folder)

                print(f'[{image}:latest]')
                Main._build_docker_image(build_path, image)

                # TODO: Push image to dockerhub
                docker.push(image)


if __name__ == '__main__':
    fire.Fire(Main)