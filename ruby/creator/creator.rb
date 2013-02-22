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
<#{uri}> rdfs:label ?label.
}
UNION
{
<#{uri}> skos:prefLabel ?label.
}

}
END
  labels = $sparql.query(query)
  puts "LABELS: " + labels.inspect
  if (labels.length == 0) or (labels[0][:label].nil?) then
    return uri 
  else 
    return labels[0][:label].to_s
  end
end

get '/' do
  query = NAMESPACES+<<END

select distinct ?category ?label where {
?category rdf:type pw:CriterionCategory.
?category rdfs:label ?label
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
?attribute rdf:type pw:Attribute.
?attribute rdfs:label ?label.
?attribute pw:criterioncategory <#{category}>.
} ORDER BY ?label
	
END

  attributes = $sparql.query( query )

  markaby :attributeSelect, :locals => {:pageTitle => "Home: SCAPE",
    :category => category,
    :categoryLabel => categoryLabel,
    :attributes => attributes}

end

get '/attribute' do
  category = params[:category]
  categoryLabel = getLabel(category)
  attribute = params[:attribute]
  attributeLabel = getLabel(attribute)
  
  query = NAMESPACES+<<END
select distinct ?measure ?label where {
?measure rdf:type pw:Measure.
<#{attribute}> pw:measure ?measure.
optional {
  ?measure rdfs:label ?label.
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

end

get '/measure' do
  category = params[:category]
  categoryLabel = getLabel(category)
  attribute = params[:attribute]
  attributeLabel = getLabel(attribute)
  measure = params[:measure]
  measureLabel = getLabel(measure)
  puts measureLabel

  query = NAMESPACES+<<END
select distinct ?scale ?label {
<#{measure}> pw:scale ?scale.
optional {
  ?scale skos:prefLabel ?label
}
}
END

  scale = $sparql.query( query )
  puts scale.inspect

  query = NAMESPACES+<<END
select distinct ?modality ?label where {
?modality rdf:type modalities:Modality.
?modality skos:prefLabel ?label.
}
END

  modalities = $sparql.query( query )

  markaby :modalitySelect, :locals => {:pageTitle => "Home: SCAPE",
    :category => category,
    :categoryLabel => categoryLabel,
    :attribute => attribute,
    :attributeLabel => attributeLabel,
    :measure => measure,
    :measureLabel => measureLabel,
    :scale => scale,
    :modalities => modalities
  }

end

get '/modality' do
  category = params[:category]
  categoryLabel = getLabel(category)
  attribute = params[:attribute]
  attributeLabel = getLabel(attribute)
  measure = params[:measure]
  measureLabel = getLabel(measure)
  modality = params[:modality]
  modalityLabel = getLabel(modality)
  scale = params[:scale]
  puts scale
  scaleLabel = getLabel(scale)
  puts scaleLabel
  value = params[:value]

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
    :value => value
  }

end
