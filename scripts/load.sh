#!/bin/sh

export TDBROOT=~/Documents/tdb
PATH=$PATH:$TDBROOT/bin
DATA=./kb
#TDBLOADER="tdbloader -v --debug"
TDBLOADER=tdbloader
# Clean triplestore
tdbclean $DATA

# Load into triplestore
#tdbloader --loc=$DATA --graph=http://www.whatever.com/modalities ontologies/modalities.ttl
#tdbloader --loc=$DATA --graph=http://www.whatever.com/modalities ontologies/qualifiers.ttl
#tdbloader --loc=$DATA --graph=http://www.whatever.com/control ontologies/control-policy.owl
#tdbloader --loc=$DATA --graph=http://www.whatever.com/domain ontologies/domain.owl
#tdbloader --loc=$DATA --graph=http://www.whatever.com/p2 data/p2.ttl
#tdbloader --loc=$DATA --graph=http://www.whatever.com/objective data/objectives.ttl
#tdbloader --loc=$DATA --graph=http://www.whatever.com/content data/content.ttl
#tdbloader --loc=$DATA --graph=http://www.whatever.com/scenario data/scenarios.ttl

# Load schema into triplestore
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/control-policy ontologies/control-policy.ttl
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/control-policy/modalities ontologies/modalities.ttl
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/control-policy/qualifiers ontologies/qualifiers.ttl
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/preservation-case ontologies/preservation-case.ttl
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality ontologies/quality.ttl
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/attributes ontologies/attributes.ttl
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/categories ontologies/categories.ttl
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/measures ontologies/measures.ttl
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/scales ontologies/scales.ttl
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/scopes ontologies/scopes.ttl


# Load data into triplestore
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/examples data/asa_objectives.rdf
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/examples data/sb_objectives.rdf

