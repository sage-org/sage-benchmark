#!/usr/bin/env bash

#~/Téléchargements/hdt-cpp-develop/libhdt/tools/rdf2hdt ~/Documents/M1\ ALMA/Stage/rdf-store-mod/sage-client/spec/w3c/aggregates/agg01.ttl agg01.hdt

for FILE in /home/runner/Documents/M1_ALMA/Stage/sage-client/spec/w3c/*/*.ttl; do
    DEST="${FILE#*/spec/}"
    DEST="${DEST%.*}"
    DEST="/home/runner/Documents/M1_ALMA/Stage/SaGe/engine/sage-engine/data/$DEST.hdt"
    FOLDER="${DEST%/*.*}"
    # mkdir -p $FOLDER
    ~/Téléchargements/hdt-cpp-develop/libhdt/tools/rdf2hdt $FILE $DEST
    echo $FILE
done
