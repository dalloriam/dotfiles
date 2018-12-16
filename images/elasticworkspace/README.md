# ElasticWorkspace
Hot reloading for elasticsearch! This tool maintains an elasticsearch index, allowing you to clear & reapply the 
index configuration with the press of a button.


## Usage
```bash
# Run with default settings.
$ docker run --rm -it -network host dalloriam/elasticworkspace
```

## Managed files
* `data.json` -> Data to insert in the freshly-created index (one JSON object per line).
* `mapping.json` -> Elasticsearch mapping.
* `settings.json` -> Elasticsearch index settings, as usually posted to {ES_URL}/{INDEX_NAME}/_settings
