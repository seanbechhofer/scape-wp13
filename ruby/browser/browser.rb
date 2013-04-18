#!/opt/local/bin/ruby

require 'rubygems'
require 'getopt/std'
require 'sinatra'
require 'sparql/client'
require 'haml'
require 'markaby'
require 'markaby/sinatra'

set :port, 4567

BEHAVIOUR = {
  :debug => false,
  :verbose => false
}

NAMESPACES=<<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix control-policy: <http://purl.org/DP/control-policy#>
prefix modalities: <http://purl.org/DP/control-policy/modalities#>
prefix scales: <http://purl.org/DP/quality/scales#>
prefix scopes: <http://purl.org/DP/quality/scopes#>
prefix qualifiers: <http://purl.org/DP/control-policy/qualifiers#>
prefix quality: <http://purl.org/DP/quality#>
prefix foaf: <http://xmlns.com/foaf/0.1/>
prefix pc: <http://purl.org/DP/preservation-case#>

prefix dct: <http://purl.org/dc/terms/>

prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>
END

ENDPOINT="http://localhost:3333/scape/sparql"

$sparql = SPARQL::Client.new(ENDPOINT)

get '/' do
query = NAMESPACES+<<END

select distinct ?preservationCase where {
?preservationCase rdf:type pc:PreservationCase.
} ORDER BY ?preservationCase
	
END

  preservationCases = $sparql.query( query )

query = NAMESPACES+<<END

select distinct ?organization ?identifier where {
?organization rdf:type org:Organization.
?organization org:identifier ?identifier
} 
	
END

  organizations = $sparql.query( query )

query = NAMESPACES+<<END

select distinct ?measure ?label where {
?objective control-policy:property ?measure.
?measure skos:prefLabel ?label
} ORDER BY ?label
	
END

  measures = $sparql.query( query )

query = NAMESPACES+<<END

select distinct ?attribute ?label where {
?objective control-policy:property ?measure.
?measure quality:attribute ?attribute.
?attribute skos:prefLabel ?label.

} ORDER BY ?label
	
END

  attributes = $sparql.query( query )

query = NAMESPACES+<<END

select distinct ?category ?label where {
?objective control-policy:property ?measure.
?measure quality:attribute ?attribute.
?attribute quality:criterionCategory ?category.
?category skos:prefLabel ?label

} ORDER BY ?label
	
END

  categories = $sparql.query( query )


query = NAMESPACES+<<END

select distinct ?objective where {
?preservationCase pc:hasObjective ?objective.
} ORDER BY ?objective
	
END

  objectives = $sparql.query( query )

  markaby :index, :locals => {:pageTitle => "Home: SCAPE", 
    :preservationCases => preservationCases, :organizations => organizations, 
    :measures => measures, :attributes => attributes, :categories => categories, :objectives => objectives}

end # '/'

get '/preservationCase/*' do
  preservationCase = URI.unescape(params[:splat][0])
  query = NAMESPACES+<<END

select distinct ?content ?users  where {
optional {
<#{preservationCase}> pc:hasUserCommunity ?users.
}
optional {
<#{preservationCase}> pc:hasContentSet ?content.
}
}
END
  puts query if BEHAVIOUR[:verbose]
  results = $sparql.query( query )
  results.each do |result|
    puts result[:content].inspect
  end

query = NAMESPACES+<<END

select distinct ?objective ?type ?prop ?property ?modality ?qualifier ?value ?scope where {
<#{preservationCase}> pc:hasObjective ?objective.
?objective rdf:type ?type.

FILTER (?type != <http://www.w3.org/2002/07/owl#NamedIndividual>)
optional {
  ?objective pc:contentSetScope ?scope.
}
optional {
  ?objective control-policy:property ?prop.
  ?prop skos:prefLabel ?property.
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
} ORDER BY ?preservationCase
END

  objectives = $sparql.query( query )

  markaby :preservationCase, :locals => {:pageTitle => preservationCase, :preservationCase => preservationCase, :results => results, :objectives => objectives}
end #preservationCase

get '/content-set/*' do
  content = URI.unescape(params[:splat][0])
  query = NAMESPACES+<<END

select distinct ?subcontent  where {
optional {
<#{content}> pc:consistsOf ?subcontent
}
}
END
  puts query if BEHAVIOUR[:verbose]
  subcontent = $sparql.query( query )

query = NAMESPACES+<<END

select distinct ?organization  where {
<#{content}> pc:belongsToOrganization ?organization
}
END

  organization = $sparql.query( query )

  markaby :content, :locals => {:pageTitle => content, :content => content, :subcontent => subcontent, :organization => organization}
end #content-set

get '/organization/*' do
  organization = URI.unescape(params[:splat][0])
  query = NAMESPACES+<<END

select ?identifier where {
<#{organization}> org:identifier ?identifier.
}
END
  puts query if BEHAVIOUR[:verbose]
  identifiers = $sparql.query( query )

  query = NAMESPACES+<<END

select ?objective where {
?objective pc:organizationScope <#{organization}>.
}
END
  puts query if BEHAVIOUR[:verbose]
  objectives = $sparql.query( query )

  markaby :organization, :locals => {:pageTitle => organization, :organization => organization, :identifiers => identifiers, :objectives => objectives}
end #organization

get '/objective/*' do
  objective = URI.unescape(params[:splat][0])
query = NAMESPACES+<<END

select ?type ?prop ?property ?modality ?qualifier ?value ?scope where {
<#{objective}> rdf:type ?type.

FILTER (?type != <http://www.w3.org/2002/07/owl#NamedIndividual>)
optional {
  <#{objective}> pc:contentSetScope ?scope.
}
<#{objective}> control-policy:property ?prop.
optional {
  ?prop skos:prefLabel ?property.
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

query = NAMESPACES+<<END

select ?preservationCase where {
?preservationCase pc:hasObjective <#{objective}>.
} 
END

  preservationCases = $sparql.query( query ) 
  markaby :objective, :locals => {:pageTitle => objective, :objective => objective, :details => details, :preservationCases => preservationCases}
end #objective


get '/measure/*' do
  measure = URI.unescape(params[:splat][0])
  puts measure
  query = NAMESPACES+<<END

select ?label ?description ?category ?categorylabel ?attribute ?attributelabel ?attributedescription ?scale where {
<#{measure}> skos:prefLabel ?label.
optional {
  <#{measure}> dct:description ?description.
}
optional {
  <#{measure}> quality:attribute ?attribute.
}
optional {
  ?attribute skos:prefLabel ?attributelabel.
  ?attribute dct:description ?attributedescription.
  ?attribute quality:criterionCategory ?category.
  ?category skos:prefLabel ?categorylabel.
}
optional {
  <#{measure}> quality:scale ?sc.
  ?sc skos:prefLabel ?scale.
}
} 
END
  puts query if BEHAVIOUR[:verbose]
  details = $sparql.query( query )

  markaby :measure, :locals => {:pageTitle => measure, :measure => measure, :details => details}
end #measure

get '/measures' do
  query = NAMESPACES+<<END

select distinct ?measure ?label ?description ?category ?categorylabel ?attribute ?attributelabel ?attributedescription ?scale where {
?measure rdf:type quality:Measure.
?measure skos:prefLabel ?label.
optional {
  ?measure dct:description ?description.
}
optional {
  ?measure quality:attribute ?attribute.
}
optional {
  ?attribute skos:prefLabel ?attributelabel.
  ?attribute dct:description ?attributedescription.
  ?attribute quality:criterionCategory ?category.
  ?category skos:prefLabel ?categorylabel.
}
optional {
  ?measure quality:scale ?sc.
  ?sc skos:prefLabel ?scale.
}
} 
END
  puts query if BEHAVIOUR[:verbose]
  measures = $sparql.query( query )

  markaby :measures, :locals => {:pageTitle => "Measures", :measures => measures}
end #measures

get '/attribute/*' do
  attribute = URI.unescape(params[:splat][0])
  puts attribute
  query = NAMESPACES+<<END

select ?label ?description ?category ?categorylabel ?attributedescription ?scale where {
<#{attribute}> skos:prefLabel ?label.
optional {
  <#{attribute}> dct:description ?description.
}
optional {
  <#{attribute}> quality:criterionCategory ?category.
  ?category skos:prefLabel ?categorylabel.
}
} 
END
  puts query if BEHAVIOUR[:verbose]
  details = $sparql.query( query )

  query = NAMESPACES+<<END

select ?measure ?label where {
?measure quality:attribute <#{attribute}>.
?measure skos:prefLabel ?label.
} 
END
  puts query if BEHAVIOUR[:verbose]
  measures = $sparql.query( query )


  markaby :attribute, :locals => {:pageTitle => attribute, :attribute => attribute, :details => details, :measures => measures}
end #attribute

get '/attributes' do
  query = NAMESPACES+<<END

select ?attribute ?label ?description ?category ?categorylabel where {
?attribute rdf:type quality:Attribute.
?attribute skos:prefLabel ?label.
optional {
  ?attribute dct:description ?description.
}
optional {
  ?attribute quality:criterionCategory ?category.
  ?category skos:prefLabel ?categorylabel.
}
} 
END
  puts query if BEHAVIOUR[:verbose]
  attributes = $sparql.query( query )

  markaby :attributes, :locals => {:pageTitle => "Attributes", :attributes => attributes}
end #attributes

get '/criterioncategory/*' do
  category = URI.unescape(params[:splat][0])
  puts category

  query = NAMESPACES+<<END

select ?label where {
<#{category}> skos:prefLabel ?label.
} 
END
  puts query if BEHAVIOUR[:verbose]
  details = $sparql.query( query )

  query = NAMESPACES+<<END

select ?attribute ?label where {
?attribute quality:criterionCategory <#{category}>.
?attribute skos:prefLabel ?label.
} 
END
  puts query if BEHAVIOUR[:verbose]
  attributes = $sparql.query( query )

  markaby :criterioncategory, :locals => {:pageTitle => category, :category => category, :details => details, :attributes => attributes}
end #criterioncategory

get '/criterioncategories' do
  query = NAMESPACES+<<END

select ?category ?label where {
?category rdf:type quality:CriterionCategory.
?category skos:prefLabel ?label.
} 
END
  puts query if BEHAVIOUR[:verbose]
  categories = $sparql.query( query )

  markaby :criterioncategories, :locals => {:pageTitle => "Categories", :categories => categories}
end #criterioncategories

get '/category/*' do
  category = URI.unescape(params[:splat][0])
  puts category

  query = NAMESPACES+<<END

select ?label where {
<#{category}> skos:prefLabel ?label.
} 
END
  puts query if BEHAVIOUR[:verbose]
  details = $sparql.query( query )

  query = NAMESPACES+<<END

select ?criterioncategory ?label where {
<#{category}> quality:subcategory ?criterioncategory.
?criterioncategory skos:prefLabel ?label.
} 
END
  puts query if BEHAVIOUR[:verbose]
  subcategories = $sparql.query( query )

  markaby :category, :locals => {:pageTitle => category, :category => category, :details => details, :subcategories => subcategories}
end #category

get '/categories' do
  query = NAMESPACES+<<END

select ?category ?label where {
?category rdf:type quality:Category.
?category skos:prefLabel ?label.
} 
END
  puts query if BEHAVIOUR[:verbose]
  categories = $sparql.query( query )

  markaby :categories, :locals => {:pageTitle => "Categories", :categories => categories}
end #categories

