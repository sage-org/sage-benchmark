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

                DEST=/home/runner/Documents/M1_ALMA/Stage/myjenahdt-res
                mkdir -p $DEST
                /usr/lib/jvm/java-8-openjdk-amd64/bin/java -javaagent:/home/runner/programmes/idea-IC-181.5281.24/lib/idea_rt.jar=44857:/home/runner/programmes/idea-IC-181.5281.24/bin -Dfile.encoding=UTF-8 -classpath /usr/lib/jvm/java-8-openjdk-amd64/jre/lib/charsets.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/cldrdata.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/dnsns.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/icedtea-sound.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/jaccess.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/localedata.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/nashorn.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/sunec.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/sunjce_provider.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/sunpkcs11.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/ext/zipfs.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/jce.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/jsse.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/management-agent.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/resources.jar:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/rt.jar:/home/runner/Documents/M1_ALMA/Stage/myjenahdt/target/classes:/home/runner/.m2/repository/org/apache/jena/jena-arq/3.0.1/jena-arq-3.0.1.jar:/home/runner/.m2/repository/org/apache/jena/jena-core/3.0.1/jena-core-3.0.1.jar:/home/runner/.m2/repository/org/apache/jena/jena-iri/3.0.1/jena-iri-3.0.1.jar:/home/runner/.m2/repository/xerces/xercesImpl/2.11.0/xercesImpl-2.11.0.jar:/home/runner/.m2/repository/xml-apis/xml-apis/1.4.01/xml-apis-1.4.01.jar:/home/runner/.m2/repository/commons-cli/commons-cli/1.3/commons-cli-1.3.jar:/home/runner/.m2/repository/org/apache/jena/jena-shaded-guava/3.0.1/jena-shaded-guava-3.0.1.jar:/home/runner/.m2/repository/org/apache/httpcomponents/httpclient/4.2.6/httpclient-4.2.6.jar:/home/runner/.m2/repository/org/apache/httpcomponents/httpcore/4.2.5/httpcore-4.2.5.jar:/home/runner/.m2/repository/commons-codec/commons-codec/1.6/commons-codec-1.6.jar:/home/runner/.m2/repository/com/github/jsonld-java/jsonld-java/0.7.0/jsonld-java-0.7.0.jar:/home/runner/.m2/repository/com/fasterxml/jackson/core/jackson-core/2.3.3/jackson-core-2.3.3.jar:/home/runner/.m2/repository/com/fasterxml/jackson/core/jackson-databind/2.3.3/jackson-databind-2.3.3.jar:/home/runner/.m2/repository/com/fasterxml/jackson/core/jackson-annotations/2.3.0/jackson-annotations-2.3.0.jar:/home/runner/.m2/repository/commons-io/commons-io/2.4/commons-io-2.4.jar:/home/runner/.m2/repository/org/apache/httpcomponents/httpclient-cache/4.2.6/httpclient-cache-4.2.6.jar:/home/runner/.m2/repository/org/apache/thrift/libthrift/0.9.2/libthrift-0.9.2.jar:/home/runner/.m2/repository/org/slf4j/jcl-over-slf4j/1.7.12/jcl-over-slf4j-1.7.12.jar:/home/runner/.m2/repository/org/apache/commons/commons-csv/1.0/commons-csv-1.0.jar:/home/runner/.m2/repository/org/apache/commons/commons-lang3/3.3.2/commons-lang3-3.3.2.jar:/home/runner/.m2/repository/org/slf4j/slf4j-api/1.7.12/slf4j-api-1.7.12.jar:/home/runner/.m2/repository/org/slf4j/slf4j-log4j12/1.7.12/slf4j-log4j12-1.7.12.jar:/home/runner/.m2/repository/log4j/log4j/1.2.17/log4j-1.2.17.jar:/home/runner/.m2/repository/eu/wdaqua/hdt-jena/2.0/hdt-jena-2.0.jar:/home/runner/.m2/repository/eu/wdaqua/hdt-java-core/2.0/hdt-java-core-2.0.jar:/home/runner/.m2/repository/org/apache/commons/commons-compress/1.10/commons-compress-1.10.jar:/home/runner/.m2/repository/pl/edu/icm/JLargeArrays/1.6/JLargeArrays-1.6.jar:/home/runner/.m2/repository/org/apache/commons/commons-math3/3.5/commons-math3-3.5.jar:/home/runner/.m2/repository/org/apache/jena/jena-base/3.0.1/jena-base-3.0.1.jar:/home/runner/.m2/repository/com/github/andrewoma/dexx/dexx-collections/0.2/dexx-collections-0.2.jar:/home/runner/.m2/repository/eu/wdaqua/hdt-api/2.0/hdt-api-2.0.jar:/home/runner/.m2/repository/com/beust/jcommander/1.32/jcommander-1.32.jar myjenahdt.Main "/home/runner/Documents/M1_ALMA/Stage/SaGe/engine/sage-engine/data/w3c/$DIR/$ADATA.hdt" "$QUERY" 1> $DEST/res.$NAME.xml

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

#'/^<sparql/{$!{:m;N;s/>/END/;tm s/^<sparql.*END/<sparql>/g}}' w3c/entailment/sparqldl-05.srx

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

                    if ! [[ $completeness = 1.00 ]]; then
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
