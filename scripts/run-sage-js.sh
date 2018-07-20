#!/usr/bin/env bash

if ! [[ $1 ]] ; then
    FOLDER="*"
else
    FOLDER="$1"
fi

for MANIFEST in /home/runner/Documents/M1_ALMA/Stage/sage-client/spec/w3c/$FOLDER/manifest.ttl; do
    WAY="${MANIFEST%/*.ttl}"
    DIR="${WAY#*w3c/}"
    #echo $DIR
    exec 3<> /home/runner/Documents/M1_ALMA/Stage/room/w3c/$FOLDER/manifest.ttl;
    while read -r LINE; do
        #echo $LINE

        #looking for query line
        if [[ $LINE = *"qt:query "* ]] && ! [[  $LINE = "#"* ]] ; then
            AQUERY=$LINE
            AQUERY="${AQUERY%>*}"
            AQUERY="${AQUERY#*<}"
            NAME="${AQUERY%.rq}"
            AQUERY="$WAY/$AQUERY"
            #echo $AQUERY
            echo -n "$DIR/$NAME;"
            QUERY=""
            exec 4<> $AQUERY
                while read -r MUSTREMOVECOMMENTS; do
                    COMMMENTSREMOVED="${MUSTREMOVECOMMENTS%# *}"
                    #echo "$COMMMENTSREMOVED"
                    QUERY="$QUERY $COMMMENTSREMOVED"
                done <&4
            exec 4>&-

            #looking for data line and setup
            read -r LINE;
            if [[ $LINE = *"qt:data "* ]] && [[ $LINE = *".ttl"* ]]; then
                ADATA=$LINE
                ADATA="${ADATA%.ttl>*}"
                ADATA="${ADATA#*<}"
                #echo "query $QUERY"

                #looking for result line and setup
                while ! [[ $LINE = *"mf:result "* ]]; do
                    read -r LINE
                done
                EXPECT=$LINE
                EXPECT="${EXPECT%>*}"
                EXPECT="${EXPECT#*<}"

                DEST=/home/runner/Documents/M1_ALMA/Stage/room/results/$DIR
                mkdir -p $DEST
                #./../SaGe/jena/sage-jena/build/distributions/sage-jena-1.0-SNAPSHOT/bin/sage-jena -u "http://localhost:8000/sparql/$DIR$ADATA" -q "$QUERY" 1> $DEST/res.$NAME.xml

                if [[ $EXPECT = *".srx"* ]]; then
                    reference=$WAY/$EXPECT
                    results=$DEST/res.$NAME.xml

                    #reference setup
                    sed '/^<sparql/{$!{:m;s/>/END/;te;N;bm;:e;s/^<sparql.*END/<sparql>/g}}' $reference > tempRef
                    cat tempRef > _tempRef
                    xsltproc -o _tempRef my-hash.xslt tempRef
                    sort _tempRef > tempRef

                    #result setup
                    sed '/^<sparql/{$!{:m;s/>/END/;te;N;bm;:e;s/^<sparql.*END/<sparql>/g}}' $results > tempRes
                    cat tempRes > _tempRes
                    xsltproc -o _tempRes my-hash.xslt tempRes
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

                    if ! [[ $completeness = 1.00 ]] || ! [[ $soundness = 1.00 ]]; then
                        echo ""
                        cat tempRef
                        cat tempRes
                    fi

                    rm -f tempRef tempRes _tempRef _tempRes
                fi
            fi
            echo ""
        fi
    done <&3;
    exec 3>&-
done
