#!/bin/sh

# Use cmap2rdf to convert concept map to rdf format. 
# Then upload to tdb
# Then use the queries below to suck out of tdb

SAXON=~/Dropbox/bin/saxon

# Convert XML to RDF
$SAXON policies.cxl cmap2rdf.xsl policies.rdf

export TDBROOT=~/Documents/tdb
PATH=$PATH:$TDBROOT/bin

# Load into triplestore
tdbclean tdb

tdbloader policies.rdf

# Query
tdbquery --results XML --file nodes.spq > nodes.xml
tdbquery --results XML --file relationships.spq > relationships.xml

# Translate Query
$SAXON nodes.xml sparql2csv.xsl policy-nodes.csv
$SAXON relationships.xml sparql2csv.xsl policy-relationships.csv

