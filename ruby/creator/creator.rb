#!/opt/local/bin/ruby

require 'rubygems'
require 'getopt/std'
require 'sinatra'
require 'sparql/client'
require 'haml'
require 'markaby'
require 'markaby/sinatra'
require 'net/http'

set :port, 5678

# Construct a new graph URI from the current time. Bit of a hack. 

EXAMPLE = "http://scape-project.eu/DP/example-" + Time.now.utc.iso8601.to_s
puts EXAMPLE

NAMESPACES=<<END
prefix policies: <http://www.oesta.gv.at/policies/>
prefix control-policy: <http://purl.org/DP/control-policy#>
prefix preservation-case: <http://purl.org/DP/preservation-case#>
prefix modalities: <http://purl.org/DP/control-policy/modalities#>
prefix qualifiers: <http://purl.org/DP/control-policy/qualifiers#>
prefix measures: <http://purl.org/DP/quality/measures#>
prefix scales: <http://purl.org/DP/quality/scales#>
prefix scopes: <http://purl.org/DP/quality/scopes#>
prefix quality: <http://purl.org/DP/quality#>
prefix guidance: <http://purl.org/DP/guidance#>
prefix foaf: <http://xmlns.com/foaf/0.1/>

prefix dct: <http://purl.org/dc/terms/>
prefix org: <http://www.w3.org/ns/org#>
prefix premis: <http://multimedialab.elis.ugent.be/users/samcoppe/ontologies/Premis/premis.owl>
prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#>
prefix pronom: <http://reference.data.gov.uk/technical-registry/>
prefix xsd: <http://www.w3.org/2001/XMLSchema#>
prefix owl: <http://www.w3.org/2002/07/owl#>
prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix skos: <http://www.w3.org/2004/02/skos/core#>
END

BEHAVIOUR = {
  :debug => false,
  :verbose => false
}

#ENDPOINT="http://localhost:3030/etree/sparql"
#ENDPOINT="http://etree.linkedmusic.org/sparql"
ENDPOINT="http://localhost:3333/scape/sparql"
UPDATEENDPOINT="http://localhost:3333/scape/update"

$sparql = SPARQL::Client.new(ENDPOINT)
$sp_update = SPARQL::Client.new(UPDATEENDPOINT)

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
  markaby :index, :locals => {:pageTitle => "Home:SCAPE"}
end #/

get '/preservationCase' do
  query = NAMESPACES+<<END
select distinct ?preservationCase ?name where {
?preservationCase rdf:type preservation-case:PreservationCase.
optional {
  ?preservationCase skos:prefLabel ?name.
}
} 
END

  preservationCases = $sparql.query( query )

  markaby :preservationCaseSelect, :locals => {:pageTitle => "Home: SCAPE", 
  :preservationCases => preservationCases}
  
end #preservation-case

get '/objective' do
  preservationCase = params[:preservationCase]
  query = NAMESPACES+<<END

select distinct ?category ?label where {
?category rdf:type quality:CriterionCategory.
?category skos:prefLabel ?label
} ORDER BY ?label
	
END

  categories = $sparql.query( query )

  markaby :categorySelect, :locals => {:pageTitle => "Home: SCAPE", 
  :preservationCase => preservationCase,
  :categories => categories}

end # '/'

get '/category' do
  preservationCase = params[:preservationCase]
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
    :preservationCase => preservationCase,
    :category => category,
    :categoryLabel => categoryLabel,
    :attributes => attributes}

end #category

get '/attribute' do
  preservationCase = params[:preservationCase]
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
    :preservationCase => preservationCase,
    :category => category,
    :categoryLabel => categoryLabel,
    :attribute => attribute,
    :attributeLabel => attributeLabel,
    :measures => measures}

end #attribute

get '/measure' do
  preservationCase = params[:preservationCase]
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
select distinct ?restriction {
<#{measure}> quality:restriction ?restriction.
}
END

  restriction = $sparql.query( query )

  query = NAMESPACES+<<END
select distinct ?modality ?label where {
?modality skos:inScheme modalities:scheme.
?modality skos:prefLabel ?label.
}
END

  modalities = $sparql.query( query )

  query = NAMESPACES+<<END
select distinct ?guidance ?label where {
?guidance skos:inScheme guidance:scheme.
?guidance skos:prefLabel ?label.
}
END

  guidances = $sparql.query( query )

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
    :preservationCase => preservationCase,
    :category => category,
    :categoryLabel => categoryLabel,
    :attribute => attribute,
    :attributeLabel => attributeLabel,
    :measure => measure,
    :measureLabel => measureLabel,
    :scale => scale,
    :restriction => restriction,
    :modalities => modalities,
    :objectives => objectives,
    :qualifiers => qualifiers,
    :guidances => guidances
  }

end #measure

get '/details' do
  preservationCase = params[:preservationCase]
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
  guidance = params[:guidance]
  if guidance.eql?("NONE") then
    guidanceLabel = "NONE"
  else
    guidanceLabel = getLabel(guidance)
  end
  value = params[:value]
  url = params[:url]
  vFrom = params[:vFrom]
  vTo = params[:vTo]
  validFrom = params[:validFrom]
  validTo = params[:validTo]

  # puts vFrom
  # puts vTo
  # puts validFrom
  # puts validTo

  validity = {
    'from' => "NONE",
    'to' => "NONE"
  }
  if (vFrom.eql?("yes")) then
    validity['from'] = validFrom
  end
  if (vTo.eql?("yes")) then
    validity['to'] = validTo
  end

  # puts validity.inspect

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

<#{preservationCase}> control-policy:hasObjective <#{url}>.

<#{url}> a <#{type}>;
END

  if (!guidance.eql?("NONE")) then
    rdf = rdf +<<END
   dct:subject <#{guidance}>;
END
  end
  if (!validity['from'].eql?("NONE")) then
    rdf = rdf +<<END
   control-policy:validFrom "#{validity['from']}"^^xsd:dateTime;
END
  end
  if (!validity['to'].eql?("NONE")) then
    rdf = rdf +<<END
   control-policy:validTo "#{validity['from']}"^^xsd:dateTime;
END
  end
  
rdf = rdf +<<END
   control-policy:measure <#{measure}>;
   control-policy:modality <#{modality}>;
   control-policy:qualifier <#{qualifier}>;
   control-policy:value "#{value}".
END

  markaby :done, :locals => {:pageTitle => "Home: SCAPE",
    :preservationCase => preservationCase,
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
    :guidance => guidance,
    :guidanceLabel => guidanceLabel,
    :value => value,
    :url => url,
    :validity => validity,
    :rdf => rdf
  }

end #details

get '/insert' do
  preservationCase = params[:preservationCase]
  category = params[:category]
  categoryLabel = getLabel(category)
  attribute = params[:attribute]
  attributeLabel = getLabel(attribute)
  measure = params[:measure]
  measureLabel = getLabel(measure)
  modality = params[:modality]
  puts modality
  modalityLabel = getLabel(modality)
  puts modalityLabel
  qualifier = params[:qualifier]
  puts qualifier
  qualifierLabel = getLabel(qualifier)
  puts qualifierLabel
  scale = params[:scale]
  scaleLabel = getLabel(scale)
  type = params[:type]
  typeLabel = getLabel(type)
  guidance = params[:guidance]
  guidanceLabel = params[:guidanceLabel]
  value = params[:value]
  validFrom = params[:validFrom]
  validTo = params[:validTo]
  url = params[:url]
  rdf = params[:rdf]
  validity = {
    'from' => params[:validFrom],
    'to' => params[:validTo]
  }

  puts "Checking"
#Check to see if it's there already
  query = NAMESPACES+<<END
ask where {
{
  <#{url}> ?p ?o.
} UNION 
{
  ?s ?p <#{url}>.
}
}
END
  isItThere = $sparql.query(query)
  if isItThere then
    puts "It's there"
    markaby :doneBadURI, :locals => {:pageTitle => "Home: SCAPE",
      :preservationCase => preservationCase,
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
      :guidance => guidance,
      :guidanceLabel => guidanceLabel,
      :validity => validity,
      :validFrom => validFrom,
      :validTo => validTo,
      :value => value,
      :url => url,
      :rdf => rdf
    }
  else
    puts "It's not there"

    update = NAMESPACES+<<END

insert data { graph <#{EXAMPLE}> {
<#{preservationCase}> preservation-case:hasObjective <#{url}>.
END
    if type then
      update = update + "<#{url}> rdf:type <#{type}>.\n"
    end
    if measure then
      update = update + "<#{url}> control-policy:measure <#{measure}>.\n"
    end
    if modality then
      update = update + "<#{url}> control-policy:modality <#{modality}>.\n"
    end
    if qualifier then
      update = update + "<#{url}> control-policy:qualifier <#{qualifier}>.\n"
    end
    if value then
      update = update + "<#{url}> control-policy:value \"#{value}\".\n"
    end
    if !guidance.eql?("NONE") then
      update = update + "<#{url}> dct:subject <#{guidance}>.\n"
    end
    if (!validFrom.eql?("NONE")) then
      update = update + "<#{url}> control-policy:validFrom \"#{validFrom}\"^^xsd:dateTime.\n"
    end
    if (!validTo.eql?("NONE")) then
      update = update + "<#{url}> control-policy:validTo \"#{validTo}\"^^xsd:dateTime.\n"
    end
    update = update + "}}"
    puts update
    request = Net::HTTP::Post.new("/scape/update")
    request.set_form_data({'update' => update})
    response = Net::HTTP.new("localhost", 3333).start {|http| http.request(request) }
    puts "Response #{response.code} #{response.message}: #{response.body}"
    markaby :inserted, :locals => {:pageTitle => "Home:SCAPE", :response => response,
      :preservationCase => preservationCase,
      :graph => EXAMPLE}
  end #else
end #insert


get '/createPreservationCase' do
  preservationCase = params[:preservationCase]
  userCommunity = params[:userCommunity]
  contentSet = params[:contentSet]
  name = params[:name]

  content = ""
  if !contentSet.eql?("") then
    content = "<#{preservationCase}> preservation-case:hasContentSet <#{contentSet}>. <#{contentSet}> rdf:type preservation-case:ContentSet."
  end

  community = ""
  if !userCommunity.eql?("") then
    community = "<#{preservationCase}> preservation-case:hasUserCommunity <#{userCommunity}>.
"
  end

  update = NAMESPACES+<<END

insert data { graph <#{EXAMPLE}> {
<#{preservationCase}> rdf:type preservation-case:PreservationCase.
<#{preservationCase}> skos:prefLabel "#{name}".

#{content}

#{community}

}}
END

  puts update
  request = Net::HTTP::Post.new("/scape/update")
  request.set_form_data({'update' => update})
  response = Net::HTTP.new("localhost", 3333).start {|http| http.request(request) }
  puts "Response #{response.code} #{response.message}: #{response.body}"
  
  query = NAMESPACES+<<END
select distinct ?preservationCase ?name where {
?preservationCase rdf:type preservation-case:PreservationCase.
optional {
?preservationCase skos:prefLabel ?name.
}
} 
END

  preservationCases = $sparql.query( query )

  markaby :preservationCaseSelect, :locals => {:pageTitle => "Home: SCAPE", 
  :preservationCases => preservationCases}

end #createPreservationCase

