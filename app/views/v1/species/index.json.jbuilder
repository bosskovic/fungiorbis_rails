json.status :success

json.links do
  json.species species_url_template
  json.set! 'species.characteristics', characteristic_url_template unless expand?(:characteristics, @inclusions)
  json.set! 'species.characteristics.reference', reference_url_template unless expand?('characteristics.reference', @inclusions)
end

json.species @species, partial: 'v1/species/species',
             collection: @species,
             as: :species,
             inclusions: @inclusions,
             fields: @fields,
             nested_fields: @nested_fields

json.meta do
  json.species do
    json.partial! 'v1/common/meta'
  end
end