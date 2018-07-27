#!/usr/bin/env bash

#~/Téléchargements/hdt-cpp-develop/libhdt/tools/rdf2hdt ~/Documents/M1\ ALMA/Stage/rdf-store-mod/sage-client/spec/w3c/aggregates/agg01.ttl agg01.hdt
for WAY in /home/runner/Documents/M1_ALMA/Stage/sage-client/spec/w3c/$1/*.rq; do
    WAY="${WAY%.rq}"
    FILE="${WAY#*/$1/}"
    echo $FILE
    if [ -a $WAY.srx ] && [ -a $WAY.ttl ]
        then
        QUERY="$(tr -s '\n"' ' \"' < $WAY.rq)"
        #QUERY="select * where { ?xptdr ?fml ?trololo } limit 10"
        mkdir -p /home/runner/Documents/M1_ALMA/Stage/sage-client/test/oracles/$1
        ./../SaGe/jena/sage-jena/build/distributions/sage-jena-1.0-SNAPSHOT/bin/sage-jena -u "http://localhost:8000/sparql/$FILE" -q "$QUERY" 1> ~/Documents/M1_ALMA/Stage/sage-client/test/oracles/$1/oracle.$FILE.json
    fi
done

#    DEST="${FILE#*/spec/}"
#    DEST="${DEST%.*}"
#    DEST="/home/runner/Documents/M1_ALMA/Stage/SaGe/engine/sage-engine/data/$DEST.hdt"
#    FOLDER="${DEST%/*.*}"
#     mkdir -p $FOLDER
#    ~/Téléchargements/hdt-cpp-develop/libhdt/tools/rdf2hdt $FILE $DEST
#    echo $FILE

#/../SaGe/jena/sage-jena/build/distributions/sage-jena-1.0-SNAPSHOT/bin/sage-jena -u "$1" -q "$ADDR" 1> ~/Documents/M1\ ALMA/Stage/sage-client/test/oracles/oracle.bsbm.$i.xml
