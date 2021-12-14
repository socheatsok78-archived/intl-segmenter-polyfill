#!/bin/bash
set -euo pipefail

DICTS=(burmesedict cjdict khmerdict laodict thaidict)

for DICT in ${DICTS[@]}; do
    echo Generate filters.json fot ${DICT}
    echo '{ "strategy": "additive", "featureFilters": { "brkitr_rules": "include", "brkitr_tree": "include", "cnvalias": "include", "ulayout": "include", "brkitr_dictionaries": { "whitelist": [ "' ${DICT} '" ] } } }' > filters.json

    echo " => Building icu..."
    docker build . --file Dockerfile.icu -t icu-data
    rm -Rf build && mkdir build
    docker run -v "$PWD/build:/opt/mount" --rm "$(docker images -q icu-data)" cp /artifacts/data.h /opt/mount
    cp break_iterator.c icu.py build/

    echo " => Building break iterator engine..."
    docker build . --file Dockerfile -t build

    echo " => Copying break_iterator_${DICT}.wasm"
    docker run -v "$PWD/src:/opt/mount" --rm "$(docker images -q build)" cp /artifacts/break_iterator.wasm /opt/mount/break_iterator_${DICT}.wasm
done
