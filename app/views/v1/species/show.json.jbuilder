json.status :success

json.links do
  json.species species_index_url_template
  json.set! 'species.characteristics', characteristic_url_template unless expand?(:characteristics, @inclusions)
  json.set! 'species.characteristics.reference', reference_url_template unless expand?('characteristics.reference', @inclusions)
end

json.species do
  json.partial! 'v1/species/species',
                species: @species,
                inclusions: @inclusions,
                fields: @fields,
                nested_fields: @nested_fields
end