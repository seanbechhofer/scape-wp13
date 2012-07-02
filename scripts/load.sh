#!/bin/sh

export TDBROOT=~/Documents/tdb
PATH=$PATH:$TDBROOT/bin
DATA=./kb

# Clean triplestore
tdbclean $DATA

# Load into triplestore
tdbloader --loc=$DATA --graph=http://www.whatever.com/modalities ontologies/modalities.ttl
tdbloader --loc=$DATA --graph=http://www.whatever.com/modalities ontologies/qualifiers.ttl
tdbloader --loc=$DATA --graph=http://www.whatever.com/control ontologies/control-policy.owl
tdbloader --loc=$DATA --graph=http://www.whatever.com/domain ontologies/domain.owl
tdbloader --loc=$DATA --graph=http://www.whatever.com/p2 data/p2.ttl
tdbloader --loc=$DATA --graph=http://www.whatever.com/objective data/objectives.ttl
tdbloader --loc=$DATA --graph=http://www.whatever.com/content data/content.ttl
tdbloader --loc=$DATA --graph=http://www.whatever.com/scenario data/scenarios.ttl

