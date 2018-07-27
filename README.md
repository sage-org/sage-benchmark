# Sage-benchmark

SPARQL benchmark and tests for the evaluation and comparison of
the SaGe query engine

# Dependencies
* This test suite relies on the use of xsltproc to hash and compare xml (which is the most common return format, and the one provided by the w3c reference)

```
apt-get install xsltproc
```

# Installation
* this benchmark is compatible with the following query engines:
[jena-hdt](https://github.com/rdfhdt/hdt-java/tree/master/hdt-jena)
[sage-jena](https://github.com/Callidon/sage-jena)
[sage-client](https://github.com/Callidon/sage-client)

follow the installation instructions of the ones you require for testing.

# Running the scripts
When in this project folder, you can directly run `run-any.sh`.

`run-any.sh` takes the path to the script(s) of the query engine you wish to use:
| engine        | script name    |
| ------------- | -------------- |
| jena-hdt      | hdtsparql.sh   |
| sage-jena     | sage-jena      |
| sage-js       | sage-client.js |

* Options

```tty
bash run-any.sh
[-f <name of folder>]                                       :take the name of a unique query-expect/w3c/ subfolder (e.g "aggregates") and runs exclusively on that one.
[-j <path to the hdtsparql.sh script from jena-hdt>]        :to run queries on jena-hdt
[-g <path to the sage-jena script from sage-jena>]          :to run queries on sage-jena
[-s <path to the sage-client.js script from sage-client>]   :to run queries on sage-client
[-v]                                                        :verbose, shows differences between expected and obtained results
```

`run-any` will always output csv format as follows: `queryname;soundness;completeness`

# disclaimer

# resources

the oldies folder contains a few of the script run-any was made out of.

along with calc documents showing the completeness and soundness of various approach so far.
Most notably report compare sums up the various completion rates, along with notes of bug reasons, or mismatch reason.
