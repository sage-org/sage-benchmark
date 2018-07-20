#!/usr/bin/env bash

if ! [[ $2 ]] ; then
    FOLDER="*"
else
    FOLDER="$2"
fi

for MANIFEST in query-expect/w3c/$FOLDER/manifest.ttl; do
    WAY="${MANIFEST%/*.ttl}"
    DIR="${WAY#*w3c/}"
    #echo $DIR
    exec 3<> $MANIFEST;
    while read -r LINE; do

        # looking for query line
        if [[ $LINE = *"qt:query "* ]] && ! [[  $LINE = "#"* ]] ; then
            # slicing the name and "address" of the query
            # linking it to its path
            # and outputing it
            AQUERY=$LINE
            AQUERY="${AQUERY%>*}"
            AQUERY="${AQUERY#*<}"
            NAME="${AQUERY%.rq}"

            AQUERY="$WAY/$AQUERY"
            echo -n "$DIR/$NAME;"

            # one-lining the query from the file and
            # removing all of its comments
            QUERY=""
            exec 4<> $AQUERY
                while read -r MUSTREMOVECOMMENTS; do
                    COMMMENTSREMOVED="${MUSTREMOVECOMMENTS%# *}"
                    QUERY="$QUERY $COMMMENTSREMOVED"
                done <&4
            exec 4>&-

            # looking for data line and
            # slicing the name of the dataset
            read -r LINE;
            if [[ $LINE = *"qt:data "* ]] && [[ $LINE = *".ttl"* ]]; then
                ADATA=$LINE
                ADATA="${ADATA%.ttl>*}"
                ADATA="${ADATA#*<}"

                # looking for result line and
                # slicing the filename
                while ! [[ $LINE = *"mf:result "* ]]; do
                    read -r LINE
                done
                EXPECT=$LINE
                EXPECT="${EXPECT%>*}"
                EXPECT="${EXPECT#*<}"

                # setting up a destination for results of the execution and
                # creating any necessary path to it
                DEST=results/$DIR
                mkdir -p $DEST/

                JENACOM="/home/runner/Documents/M1_ALMA/Stage/SaGe/jena/sage-jena/build/distributions/sage-jena-1.0-SNAPSHOT/bin/sage-jena"
                `$JENACOM -u "http://localhost:8000/sparql/$DIR$ADATA" -q "$QUERY" 1> $DEST/res.$NAME.xml`

                if [[ $EXPECT = *".srx"* ]]; then
                    reference=$WAY/$EXPECT
                    results=$DEST/res.$NAME.xml

                    #reference setup
                    sed '/^<sparql/{$!{:m;s/>/END/;te;N;bm;:e;s/^<sparql.*END/<sparql>/g}}' $reference > tempRef
                    cat tempRef > _tempRef
                    xsltproc -o _tempRef scripts/hasher.xslt tempRef
                    sort _tempRef > tempRef

                    #result setup
                    sed '/^<sparql/{$!{:m;s/>/END/;te;N;bm;:e;s/^<sparql.*END/<sparql>/g}}' $results > tempRes
                    cat tempRes > _tempRes
                    xsltproc -o _tempRes scripts/hasher.xslt tempRes
                    sort _tempRes > tempRes

                    #soundness
                    groundTruth=`wc -l tempRes | sed 's/^[ ^t]*//' | cut -d' ' -f1`
                    commons=`comm -12 tempRef tempRes | wc -l`
                    soundness=`echo "scale=2; $commons/$groundTruth" | bc`
                    echo -n "$soundness;"

                    #completeness
                    groundTruth=`wc -l tempRef | sed 's/^[ ^t]*//' | cut -d' ' -f1`
                    commons=`comm -12 tempRef tempRes | wc -l`
                    completeness=`echo "scale=2; $commons/$groundTruth" | bc`
                    echo -n "$completeness;"

                    rm -f tempRef tempRes _tempRef _tempRes
                fi
            fi
            echo ""
        fi
    done <&3;
    exec 3>&-
done
