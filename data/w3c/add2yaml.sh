#!/usr/bin/env bash

YAML=../test_config.yaml

for PATH in */*.hdt; do
    PATH="${PATH#*/w3c/}"
    FILE="${PATH%.*}"
    FILE="${FILE#*/}"
    # echo $FILE;
    echo "-" >> $YAML
    echo "  name: $FILE" >> $YAML
    echo "  description: $FILE" >> $YAML
    echo "  backend: hdt-file" >> $YAML
    echo "  file: data/w3c/$PATH" >> $YAML
done