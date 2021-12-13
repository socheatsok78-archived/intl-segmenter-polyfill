#!/bin/bash
set -euo pipefail

echo " => Building icu..."
docker build . --file Dockerfile.icu -t icu-data
rm -Rf build && mkdir build
docker run -v "$PWD/build:/opt/mount" --rm "$(docker images -q icu-data)" cp /artifacts/data.h /opt/mount
cp break_iterator.c icu.py build/

echo " => Building break iterator engine..."
docker build . --file Dockerfile -t build
docker run -v "$PWD/src:/opt/mount" --rm "$(docker images -q build)" cp /artifacts/break_iterator.wasm /opt/mount
