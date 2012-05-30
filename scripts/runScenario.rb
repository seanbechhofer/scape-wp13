#!/opt/local/bin/ruby


# Very hacky script demonstrating a SPARQL query against objectives. 

require 'rubygems'
require 'sparql/client'

ENDPOINT = "http://localhost:3031/scape/sparql"

# Check the given value against the objective value according to the qualifier. 
def check(objectiveValue, candidateValue, qualifier) 
  # Currently only checking for equality
  if qualifier.eql?("") || qualifier.eql?("http://www.scape-project.eu/pw/vocab/qualifiers#EQ") then
    return objectiveValue.eql?(candidateValue)
  else
    puts "UNKNOWN OBJECTIVE"
    return false
  end
end

# SPARQL query
scenarioQuery=<<END
prefix rdf:    <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
prefix pronom: <http://pronom.nationalarchives.gov.uk/#>
prefix rdfs:   <http://www.w3.org/2000/01/rdf-schema#> 
prefix owl:        <http://www.w3.org/2002/07/owl#> 
prefix skos:       <http://www.w3.org/2004/02/skos/core#> 
prefix dct: 	    <http://purl.org/dc/terms/> 
prefix modalities:        <http://www.scape-project.eu/pw/vocab/modalities#> 
prefix control:        <http://www.scape-project.eu/pw/vocab/control-policy#> 
prefix domain:        <http://www.scape-project.eu/pw/vocab/domain#> 
prefix scape:	      <http://www.example.com/scape#>
prefix pronom:	      <http://pronom.nationalarchives.gov.uk/#>

select DISTINCT ?scenario ?content ?format ?fname ?objective ?prop ?fval ?oval ?mod ?qual where {
# scenario has an objective and content set
?scenario control:objective ?objective.
?scenario control:content ?content. 

# content set uses a format
?content domain:formatUsage ?fu.
?fu domain:format ?ffid.
?format pronom:FileFormatIdentifier ?ffid.
?format pronom:FormatName ?fname.

# objective specifies value for a property
?object a control:FormatObjective.
?objective control:property ?prop.
?objective control:value ?oval.
?objective control:modality ?mod.
OPTIONAL {
  ?objective control:modality ?qual.
}

# format has a value for the property. 
OPTIONAL {
  ?format ?prop ?fval.
}
}
END

sparql = SPARQL::Client.new(ENDPOINT)

# Hash to record the results.
scenarios = {}

results = sparql.query(scenarioQuery)
results.each do |result|
  # First populate the hash and assume everything's ok. 
  if !scenarios[result[:scenario]] then
    scenarios[result[:scenario]] = {
      :ok => true,
      :report => [] 
    }
  end
  # Now check 
  if result[:mod].to_s.eql?("http://www.scape-project.eu/pw/vocab/modalities#MUST") then
    if !check(result[:oval],result[:fval],result[:qual]) then
      scenarios[result[:scenario]][:ok] = false
      report = <<END
================================================
Scenario: #{result[:scenario]}
Objective: #{result[:objective]} FAILED

  ContentSet #{result[:content]} uses format 
    #{result[:format]} (#{result[:fname]})
  with value 
    #{result[:prop]} - #{result[:fval]} 
  rather than 
    #{result[:prop]} - #{result[:oval]}.
================================================

END
      scenarios[result[:scenario]][:report] << report
    end
  elsif result[:mod].to_s.eql?("http://www.scape-project.eu/pw/vocab/modalities#MUST_NOT") then
    if check(result[:oval],result[:fval],result[:qual]) then
      scenarios[result[:scenario]][:ok] = false
      report = <<END
================================================
Scenario: #{result[:scenario]}
Objective: #{result[:objective]} Faile

  ContentSet #{result[:content]} uses format 
    #{result[:format]} (#{result[:fname]})
  with value 
    #{result[:prop]} - #{result[:fval]} 
  which is not allowed
================================================

END
      scenarios[result[:scenario]][:report] << report
    end
  elsif result[:mod].to_s.eql?("http://www.scape-project.eu/pw/vocab/modalities#SHOULD") then
    if !check(result[:oval],result[:fval],result[:qual]) then
      scenarios[result[:scenario]][:ok] = false
      report = <<END
================================================
Scenario: #{result[:scenario]}
Objective: #{result[:objective]} Under Threat

  ContentSet #{result[:content]} uses format 
    #{result[:format]} (#{result[:fname]})
  with value 
    #{result[:prop]} - #{result[:fval]} 
  rather than 
    #{result[:prop]} - #{result[:oval]}.
================================================

END
      scenarios[result[:scenario]][:report] << report
    end
  elsif result[:mod].to_s.eql?("http://www.scape-project.eu/pw/vocab/modalities#SHOULD_NOT") then
    if check(result[:oval],result[:fval],result[:qual]) then
      scenarios[result[:scenario]][:ok] = false
      report = <<END
================================================
Scenario: #{result[:scenario]}
Objective: #{result[:objective]} Under Threat

  ContentSet #{result[:content]} uses format 
    #{result[:format]} (#{result[:fname]})
  with value 
    #{result[:prop]} - #{result[:fval]} 
  which is not allowed
================================================

END
      scenarios[result[:scenario]][:report] << report
    end
  end
end

scenarios.each do |scenario, details| 
#  puts scenario
#  puts details
  puts "+++++++++++++++++++++++++++++++++++++++++++++++"
  if details[:ok] then
    puts "#{scenario} GOOD"
  else
    puts "#{scenario} BAD"
    details[:report].each do |report|
      puts report
    end
  end
  puts "+++++++++++++++++++++++++++++++++++++++++++++++"

end
