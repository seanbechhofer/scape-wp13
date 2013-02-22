#!/opt/local/bin/ruby

require 'rubygems'
require 'getopt/std'
require 'sinatra'
require 'sparql/client'
require 'haml'
require 'markaby'
require 'markaby/sinatra'

BEHAVIOUR = {
  :debug => false,
  :verbose => false
}

#ENDPOINT="http://localhost:3030/etree/sparql"
#ENDPOINT="http://etree.linkedmusic.org/sparql"
ENDPOINT="http://localhost:3333/scape/sparql"

$sparql = SPARQL::Client.new(ENDPOINT)

get '/' do
query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select distinct ?scenario where {
?scenario rdf:type pw:Scenario.
} ORDER BY ?scenario
	
END

  scenarios = $sparql.query( query )

query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select distinct ?organization ?identifier where {
?organization rdf:type org:Organization.
?organization org:identifier ?identifier
} 
	
END

  organizations = $sparql.query( query )

query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select distinct ?measure ?label where {
?objective control-policy:property ?measure.
?measure rdfs:label ?label
} ORDER BY ?label
	
END

  measures = $sparql.query( query )

query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select distinct ?objective where {
?scenario pw:hasObjective ?objective.
} ORDER BY ?objective
	
END

  objectives = $sparql.query( query )

  markaby :index, :locals => {:pageTitle => "Home: SCAPE", 
    :scenarios => scenarios, :organizations => organizations, 
    :measures => measures, :objectives => objectives}

end # '/'

get '/scenario/*' do
  scenario = URI.unescape(params[:splat][0])
  query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select distinct ?content ?users  where {
optional {
<#{scenario}> pw:hasUserCommunity ?users.
}
optional {
<#{scenario}> pw:hasContentSet ?content.
}
}
END
  puts query if BEHAVIOUR[:verbose]
  results = $sparql.query( query )
  results.each do |result|
    puts result[:content].inspect
  end

query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select distinct ?objective ?type ?property ?modality ?qualifier ?value ?scope where {
<#{scenario}> pw:hasObjective ?objective.
?objective rdf:type ?objtype.
?objtype rdfs:label ?type.
FILTER (?type != <http://www.w3.org/2002/07/owl#NamedIndividual>)
optional {
  ?objective pw:contentSetScope ?scope.
}
optional {
  ?objective control-policy:property ?prop.
  ?prop rdfs:label ?property.
}
optional {
  ?objective control-policy:value ?value.
}
optional {
  ?objective control-policy:modality ?m.
  ?m skos:prefLabel ?modality.
}
optional {
  ?objective control-policy:qualifier ?q.
  ?q skos:prefLabel ?qualifier.
}
} ORDER BY ?scenario
END

  objectives = $sparql.query( query )

  markaby :scenario, :locals => {:pageTitle => scenario, :scenario => scenario, :results => results, :objectives => objectives}
end #scenario

get '/content-set/*' do
  content = URI.unescape(params[:splat][0])
  query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select distinct ?subcontent  where {
optional {
<#{content}> pw:consistsOf ?subcontent
}
}
END
  puts query if BEHAVIOUR[:verbose]
  subcontent = $sparql.query( query )

query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select distinct ?organization  where {
<#{content}> pw:belongsToOrganization ?organization
}
END

  organization = $sparql.query( query )

  markaby :content, :locals => {:pageTitle => content, :content => content, :subcontent => subcontent, :organization => organization}
end #content-set

get '/organization/*' do
  organization = URI.unescape(params[:splat][0])
  query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select ?identifier where {
<#{organization}> org:identifier ?identifier.
}
END
  puts query if BEHAVIOUR[:verbose]
  identifiers = $sparql.query( query )

  query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select ?objective where {
?objective pw:organizationScope <#{organization}>.
}
END
  puts query if BEHAVIOUR[:verbose]
  objectives = $sparql.query( query )

  markaby :organization, :locals => {:pageTitle => organization, :organization => organization, :identifiers => identifiers, :objectives => objectives}
end

get '/objective/*' do
  objective = URI.unescape(params[:splat][0])
query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select ?type ?prop ?property ?modality ?qualifier ?value ?scope where {
<#{objective}> rdf:type ?objtype.
?objtype rdfs:label ?type.
FILTER (?type != <http://www.w3.org/2002/07/owl#NamedIndividual>)
optional {
  <#{objective}> pw:contentSetScope ?scope.
}
<#{objective}> control-policy:property ?prop.
optional {
  ?prop rdfs:label ?property.
}
optional {
  <#{objective}> control-policy:value ?value.
}
optional {
  <#{objective}> control-policy:modality ?m.
  ?m skos:prefLabel ?modality.
}
optional {
  <#{objective}> control-policy:qualifier ?q.
  ?q skos:prefLabel ?qualifier.
}
} 
END

  details = $sparql.query( query )
  markaby :objective, :locals => {:pageTitle => objective, :objective => objective, :details => details}
end #objective


get '/measure/*' do
  measure = URI.unescape(params[:splat][0])
  query = <<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix modalities: <http://scape-project.eu/pw/vocab/modalities#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix scales: <http://scape-project.eu/pw/vocab/scales#>
prefix control-policy: <http://scape-project.eu/pw/vocab/control-policy#>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix mcat: <http://scape-project.eu/pw/vocab/mcat#>
prefix metrics: <http://scape-project.eu/pw/vocab/metrics#>
prefix qualifiers: <http://scape-project.eu/pw/vocab/qualifiers#>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>

select ?label ?description ?attlabel ?attdescription ?scale where {
<#{measure}> rdfs:label ?label.
optional {
  <#{measure}> pw:description ?description.
}
optional {
  <#{measure}> pw:attribute ?att.
}
optional {
  ?att rdfs:label ?attlabel.
  ?att pw:description ?attdescription.
}
optional {
  <#{measure}> pw:scale ?sc.
  ?sc skos:prefLabel ?scale.
}
} 
END
  puts query if BEHAVIOUR[:verbose]
  details = $sparql.query( query )

  markaby :measure, :locals => {:pageTitle => measure, :measure => measure, :details => details}
end #measure
