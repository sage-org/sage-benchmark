#!/usr/bin/env bash

hashxml() {
  sed '/^<sparql/{$!{:m;s/>/END/;te;N;bm;:e;s/^<sparql.*END/<sparql>/g}}' $1 > $2
  xsltproc -o _temp tools/hasher.xslt $2
  sort _temp > $2
}

compare() {
  groundTruth=`wc -l $1 | sed 's/^[ ^t]*//' | cut -d' ' -f1`
  commons=`comm -12 $2 $1 | wc -l`
  comparison=`echo "scale=2; $commons/$groundTruth" | bc`
  echo -n "$comparison;"
}

log() {
  if [[ $verbose ]] && [[ $completeness != 1.00 || $soundness != 1.00 ]]; then
      echo ""
      cat tempRef
      cat tempRes
  fi
}

usage() {
  echo "Usage: $0 [-v] [-f <name of folder to parse || *>] [-j <jena use path>] [-g <sage-jena use path>] [-s <sage js use path>]" 1>&2;
  exit 1;
}

FOLDER="*"

while getopts ":f:j:g:s:v" o; do
    case "${o}" in
        f)
          FOLDER=${OPTARG}
          ;;
        j)
          jenapath=${OPTARG}
          ;;
        g)
          sagejenapath=${OPTARG}
          ;;
        s)
          sagejspath=${OPTARG}
          ;;
        v)
          verbose=1
          ;;
        *)
          usage
          ;;
    esac
done
shift $((OPTIND-1))

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

                if [[ $EXPECT = *".srx"* ]]; then
                    reference=$WAY/$EXPECT
                    hashxml "$reference" "tempRef"

                    # for every kind of query engine supplied
                    # set the destination to store query results
                    # generate, format and compare
                    # log accordingly
                    if [[ $jenapath ]]; then
                      DEST=results/jena/$DIR
                      mkdir -p $DEST/

                      iwantmeback=`pwd`
                      jenafolder="${jenapath%bin*.sh}"

                      cd $jenafolder

                      `$jenapath $iwantmeback/data/w3c/$DIR/$ADATA.hdt "$QUERY" 1> $iwantmeback/$DEST/res.$NAME.hashed`

                      cd $iwantmeback

                      results=$DEST/res.$NAME.hashed

                      # '/^<sparql/{$!{:m;s/>/END/;te;N;bm;:e;s/^<sparql.*END/<sparql>/g}}'
                      #'/^\[INFO\]/{$!{:m;N;s/\[INFO\].*/END/;tm;s/[END]*/ /g}}'
                      # '/^\[INFO\]/{$!{:m;N;s/\[INFO\]/a/;tm;s/*/ /g}}'
                      # 's/\[INFO\].*/ /g'

                      sed '/^\[INFO\]/{$!{:m;N;s/.*\[INFO\].*/ /;tm;N;s/.*\n//g}}' $results > _temp
                      sed 's/^ //' _temp > tempRes
                      sed 's/,//g' tempRes > _temp
                      sed -e 's/\r//g' _temp > tempRes
                      sed 's/""//g' tempRes > _temp
                      cat _temp > tempRes

                      exec 5<> $results
                          while read -r ISITBOOLEAN; do
                              if [ "$ISITBOOLEAN" == "true" ] || [ "$ISITBOOLEAN" == "false" ] ; then
                                echo "$ISITBOOLEAN" > tempRes
                              fi
                          done <&5
                      exec 5>&-

                      echo '<?xml version="1.0"?>' >> tempRes
                      sort tempRes > _temp
                      cat _temp > tempRes

                      # soundness
                      compare tempRes tempRef
                      soundness=$comparison
                      # completeness
                      compare tempRef tempRes
                      completeness=$comparison

                      diff tempRef tempRes > damn.txt

                      log
                    fi

                    if [[ $sagejenapath ]]; then
                      DEST=results/sagejena/$DIR
                      mkdir -p $DEST/

                      `$sagejenapath -u "http://localhost:8000/sparql/$DIR$ADATA" -q "$QUERY" 1> $DEST/res.$NAME.xml`

                      results=$DEST/res.$NAME.xml
                      hashxml "$results" "tempRes"

                      # soundness
                      compare tempRes tempRef
                      soundness=$comparison
                      # completeness
                      compare tempRef tempRes
                      completeness=$comparison

                      log
                    fi

                    if [[ $sagejspath ]]; then
                      # ./../SaGe/sage-client/bin/sage-client.js -t xml http://localhost:8000/sparql/functionsdata -f w3c/functions/strlang02.rq
                      DEST=results/sagejs/$DIR
                      mkdir -p $DEST/

                      `node $sagejspath -t xml http://localhost:8000/sparql/$DIR$ADATA -q "$QUERY" 1> $DEST/res.$NAME.xml`

                      results=$DEST/res.$NAME.xml
                      hashxml "$results" "tempRes"

                      # soundness
                      compare tempRes tempRef
                      soundness=$comparison
                      # completeness
                      compare tempRef tempRes
                      completeness=$comparison

                      log
                    fi

                    rm -f tempRef tempRes _temp
                fi
            fi
            echo ""
        fi
    done <&3;
    exec 3>&-
done
