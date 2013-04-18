#!/opt/local/bin/ruby

require 'rubygems'
require 'getopt/std'
require 'sinatra'
require 'sparql/client'
require 'haml'
require 'markaby'
require 'markaby/sinatra'

set :port, 5678

NAMESPACES=<<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix control-policy: <http://purl.org/DP/control-policy#>
prefix modalities: <http://purl.org/DP/control-policy/modalities#>
prefix scales: <http://purl.org/DP/quality/scales#>
prefix scopes: <http://purl.org/DP/quality/scopes#>
prefix qualifiers: <http://purl.org/DP/control-policy/qualifiers#>
prefix quality: <http://purl.org/DP/quality#>
prefix foaf: <http://xmlns.com/foaf/0.1/>

prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix measures: <http://scape-project.eu/pw/vocab/measures/>
prefix pw: <http://scape-project.eu/pw/vocab/>
prefix skos: <http://www.w3.org/2004/02/skos/core#>
END

BEHAVIOUR = {
  :debug => false,
  :verbose => false
}

#ENDPOINT="http://localhost:3030/etree/sparql"
#ENDPOINT="http://etree.linkedmusic.org/sparql"
ENDPOINT="http://localhost:3333/scape/sparql"

$sparql = SPARQL::Client.new(ENDPOINT)

def getLabel(uri) 
  query = NAMESPACES+<<END
select ?label where {
{
<#{uri}> skos:prefLabel ?label.
}
UNION
{
<#{uri}> skos:prefLabel ?label.
}

}
END
  labels = $sparql.query(query)
#  puts "LABELS: " + labels.inspect
  if (labels.length == 0) or (labels[0][:label].nil?) then
    return uri 
  else 
    return labels[0][:label].to_s
  end
end

get '/' do
  query = NAMESPACES+<<END

select distinct ?category ?label where {
?category rdf:type quality:CriterionCategory.
?category skos:prefLabel ?label
} ORDER BY ?label
	
END

  categories = $sparql.query( query )

  markaby :categorySelect, :locals => {:pageTitle => "Home: SCAPE", 
  :categories => categories}

end # '/'

get '/category' do
  category = params[:category]
  categoryLabel = getLabel(category)

  query = NAMESPACES+<<END
select distinct ?attribute ?label where {
?attribute rdf:type quality:Attribute.
?attribute skos:prefLabel ?label.
?attribute quality:criterionCategory <#{category}>.
} ORDER BY ?label
	
END

  attributes = $sparql.query( query )

  markaby :attributeSelect, :locals => {:pageTitle => "Home: SCAPE",
    :category => category,
    :categoryLabel => categoryLabel,
    :attributes => attributes}

end #category

get '/attribute' do
  category = params[:category]
  categoryLabel = getLabel(category)
  attribute = params[:attribute]
  attributeLabel = getLabel(attribute)
  
  query = NAMESPACES+<<END
select distinct ?measure ?label where {
?measure rdf:type quality:Measure.
<#{attribute}> quality:measure ?measure.
optional {
  ?measure skos:prefLabel ?label.
}
} ORDER BY ?label
	
END

  measures = $sparql.query( query )

  markaby :measureSelect, :locals => {:pageTitle => "Home: SCAPE",
    :category => category,
    :categoryLabel => categoryLabel,
    :attribute => attribute,
    :attributeLabel => attributeLabel,
    :measures => measures}

end #attribute

get '/measure' do
  category = params[:category]
  categoryLabel = getLabel(category)
  attribute = params[:attribute]
  attributeLabel = getLabel(attribute)
  measure = params[:measure]
  measureLabel = getLabel(measure)

  query = NAMESPACES+<<END
select distinct ?scale ?label {
<#{measure}> quality:scale ?scale.
optional {
  ?scale skos:prefLabel ?label
}
}
END

  scale = $sparql.query( query )

  query = NAMESPACES+<<END
select distinct ?modality ?label where {
?modality skos:inScheme modalities:scheme.
?modality skos:prefLabel ?label.
}
END

  modalities = $sparql.query( query )

  query = NAMESPACES+<<END
select distinct ?qual ?label where {
?qual skos:inScheme qualifiers:scheme.
?qual skos:prefLabel ?label.
}
END

  qualifiers = $sparql.query( query )
#  puts qualifiers[0][:qual]
#  puts qualifiers.inspect

  query = NAMESPACES+<<END
select distinct ?objective ?label where {
?objective rdfs:subClassOf control-policy:Objective.
OPTIONAL {
  ?objective skos:prefLabel ?label.
  }
}
END

  objectives = $sparql.query( query )
  puts objectives.inspect

  markaby :detailsSelect, :locals => {:pageTitle => "Home: SCAPE",
    :category => category,
    :categoryLabel => categoryLabel,
    :attribute => attribute,
    :attributeLabel => attributeLabel,
    :measure => measure,
    :measureLabel => measureLabel,
    :scale => scale,
    :modalities => modalities,
    :objectives => objectives,
    :qualifiers => qualifiers
  }

end #measure

get '/details' do
  category = params[:category]
  categoryLabel = getLabel(category)
  attribute = params[:attribute]
  attributeLabel = getLabel(attribute)
  measure = params[:measure]
  measureLabel = getLabel(measure)
  modality = params[:modality]
  modalityLabel = getLabel(modality)
  qualifier = params[:qualifier]
  puts qualifier
  qualifierLabel = getLabel(qualifier)
  puts qualifierLabel
  scale = params[:scale]
  scaleLabel = getLabel(scale)
  type = params[:type]
  typeLabel = getLabel(type)
  value = params[:value]
  name = params[:name]

  rdf = <<END
@prefix rdf:
    <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .
@prefix rdfs:
    <http://www.w3.org/2000/01/rdf-schema#> .
@prefix skos:
    <http://www.w3.org/2004/02/skos/core#> .
@prefix dct:
    <http://purl.org/dc/terms/> .
@prefix control-policy:
    <http://purl.org/DP/control-policy#> .
@prefix modalities:
    <http://purl.org/DP/control-policy/modalities#> .
@prefix qualifiers:
    <http://purl.org/DP/control-policy/qualifiers#> .
@prefix quality:
    <http://purl.org/DP/quality#> .
@prefix : 
    <http://sean.bechhofer.name/DP/example#> .

#{name} a <#{type}>;
   control-policy:property <#{measure}>;
   control-policy:modality <#{modality}>;
   control-policy:qualifier <#{qualifier}>;
   control-policy:value "#{value}".
END

  markaby :done, :locals => {:pageTitle => "Home: SCAPE",
    :category => category,
    :categoryLabel => categoryLabel,
    :attribute => attribute,
    :attributeLabel => attributeLabel,
    :measure => measure,
    :measureLabel => measureLabel,
    :modality => modality,
    :modalityLabel => modalityLabel,
    :scale => scale,
    :scaleLabel => scaleLabel,
    :qualifier => qualifier,
    :qualifierLabel => qualifierLabel,
    :type => type,
    :typeLabel => typeLabel,
    :value => value,
    :name => name,
    :rdf => rdf
  }

end #modality
