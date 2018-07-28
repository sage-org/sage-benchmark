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

additionally, if testing any of the sage query-engines, you will need to setup a server, using the [sage-engine](https://github.com/sage-org/sage-engine) server system, and restoring a docker image of it (please see instructions on its page).
and launching it using the config file from sage-benchmark (located in data) (which includes all the datasets required)

```
docker run -v <path-to-this-repo>/data/:/opt/data -p 8000:8000 callidon/sage sage /opt/data/test_config.yaml
```

please not that the 8000 port is required (altough it could be changed manually in the script).
You could also run the sage-engine without using the docker image, and if you do, be sure to use the correct config file.

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
Some queries are removed from the benchmark, because they either have a format that is not  handled by the testing process properly yet (json/csv responses)
others are removed because there is no support for ontology and inferences, but it is not seen as an issue in the query engine at the moment.
all queries set aside can be found in the bottom section of the calc document "report-compare"

# resources

the oldies folder contains a few of the script run-any was made out of.

along with calc documents showing the completeness and soundness of various approaches so far.
Most notably report compare sums up the various completion rates, along with notes of bug reasons, or mismatch reason.
