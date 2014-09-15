json.status :success

json.links do
  json.species species_index_url_template
end

json.species do
  json.partial! 'v1/species/species', species: @species, options: { expand: [:characteristics] }
end