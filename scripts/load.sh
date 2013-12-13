#!/bin/sh

OPEN=false
while getopts "d" flag
do
   case $flag in
   d) INSTANCES=true
   ;;
   *) echo Usage
   ;;
   esac
done

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
# $TDBLOADER --loc=$DATA --graph=http://purl.org/DP/control-policy ontologies/control-policy.ttl
# $TDBLOADER --loc=$DATA --graph=http://purl.org/DP/control-policy/modalities ontologies/modalities.ttl
# $TDBLOADER --loc=$DATA --graph=http://purl.org/DP/control-policy/qualifiers ontologies/qualifiers.ttl
# $TDBLOADER --loc=$DATA --graph=http://purl.org/DP/preservation-case ontologies/preservation-case.ttl
# $TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality ontologies/quality.ttl
# $TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/attributes ontologies/attributes.ttl
# $TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/categories ontologies/categories.ttl
# $TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/measures ontologies/measures.ttl
# $TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/scales ontologies/scales.ttl
# $TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/scopes ontologies/scopes.ttl
# $TDBLOADER --loc=$DATA --graph=http://purl.org/DP/guidance-policy ontologies/guidance-policy.ttl
# $TDBLOADER --loc=$DATA --graph=http://id.loc.gov/vocabulary/iso639-2 ontologies/iso639-2.rdf
# $TDBLOADER --loc=$DATA --graph=http://id.loc.gov/vocabulary/countries ontologies/countries.rdf

$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/control-policy ontologies/control-policy.rdf
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/control-policy/modalities ontologies/control-policy_modalities.rdf
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/control-policy/qualifiers ontologies/control-policy_qualifiers.rdf
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/preservation-case ontologies/preservation-case.rdf
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality ontologies/quality.rdf
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/attributes ontologies/quality_attributes.rdf
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/categories ontologies/quality_categories.rdf
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/measures ontologies/quality_measures.rdf
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/scales ontologies/quality_scales.rdf
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/quality/scopes ontologies/quality_scopes.rdf
$TDBLOADER --loc=$DATA --graph=http://purl.org/DP/guidance-policy ontologies/guidance-policy.rdf
$TDBLOADER --loc=$DATA --graph=http://id.loc.gov/vocabulary/iso639-2 ontologies/iso639-2.rdf
$TDBLOADER --loc=$DATA --graph=http://id.loc.gov/vocabulary/countries ontologies/countries.rdf

if $INSTANCES
then
# Load data into triplestore
    $TDBLOADER --loc=$DATA --graph=http://sean.bechhofer.name/DP/asa data/asa_policies.rdf
    $TDBLOADER --loc=$DATA --graph=http://sean.bechhofer.name/DP/sb data/sb_objectives.rdf
    $TDBLOADER --loc=$DATA --graph=http://sean.bechhofer.name/DP/stfc data/stfc.ttl
    $TDBLOADER --loc=$DATA --graph=http://sean.bechhofer.name/DP/bl data/bl_policies.rdf
fi

