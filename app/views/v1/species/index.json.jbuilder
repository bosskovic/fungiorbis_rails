json.status :success

json.links do
  json.species species_url_template
end

json.species @species, partial: 'v1/species/species', collection: @species, as: :species

json.meta do
  json.species do
    json.partial! 'v1/common/meta'
  end
end