from elasticsearch import Elasticsearch

from fire import Fire

from typing import Iterable, Optional

import json
import logging
import os


logging.basicConfig()
log = logging.getLogger(__name__)
log.setLevel(logging.DEBUG)


def load_data(path: str):
    with open(path, 'r') as infile:
        return json.load(infile)


class ElasticsearchWorkspace:

    def __init__(self, host: str, port: int, index_name: str, doc_type, data_dir: str) -> None:
        self._data_dir = data_dir
        self._es: Elasticsearch = Elasticsearch(hosts=[f'{host}:{port}'])

        self.doc_type = doc_type
        self.index_name = index_name

    def _get_file_data(self, key: str) -> Optional[dict]:
        fname = os.path.join(self._data_dir, key)

        if not os.path.isfile(fname):
            return None

        with open(os.path.join(self._data_dir, key), 'r') as infile:
            return json.load(infile)

    def __enter__(self):
        self.setup()
        self.update_settings()
        self.update_mapping()
        self.insert_test_data()
        return self

    def __exit__(self, type, value, traceback):
        self.teardown()

    def setup(self) -> None:
        log.info(f'Setting up the [{self.index_name}] index...')
        self._es.indices.create(self.index_name)

    def update_settings(self) -> None:
        settings = self._get_file_data('settings.json')
        if not settings:
            return

        log.info(f'Stopping index [{self.index_name}]...')

        self._es.indices.close(index=self.index_name)

        log.info(f'Loading settings from [settings.json] into index [{self.index_name}]...')
        self._es.indices.put_settings(index=self.index_name, body=settings)

        log.info(f'Starting index [{self.index_name}]...')
        self._es.indices.open(self.index_name)

    def update_mapping(self) -> None:
        mapping = self._get_file_data('mapping.json')
        if not mapping:
            return

        log.info(f'Loading mapping for doctype [{self.doc_type}]')
        self._es.indices.put_mapping(self.doc_type, index=self.index_name, body=mapping)

    def insert_test_data(self) -> None:
        test_data: Iterable[dict] = (self._get_file_data('data.json') or {'documents': []})['documents']
        if not test_data:
            return

        log.info(f'Loading test documents from [data.json]... ({len(test_data)} documents)')
        for doc in test_data:
            self._es.index(self.index_name, self.doc_type, doc)

    def teardown(self) -> None:
        log.info(f'Tearing down [{self.index_name}]...')
        self._es.indices.delete(self.index_name)


class Main:
    @staticmethod
    def start(
            data_dir: str = '.',
            index_name: str = 'hot-workspace',
            doc_type='test-document',
            es_host='localhost',
            es_port=9200):

        while True:
            with ElasticsearchWorkspace(es_host, es_port, index_name, doc_type, data_dir):
                try:
                    log.info('Up & Running.')
                    log.info('Press [enter] to teardown and refresh, or type [exit] to terminate')
                    i = input('> ')
                    if i == 'exit':
                        break

                except Exception as e:
                    log.warning(f'Got unhandled exception: {e}')

                except KeyboardInterrupt:
                    break


if __name__ == '__main__':
    Fire(Main)
