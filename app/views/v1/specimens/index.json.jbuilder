json.status :success unless @filter

json.links do
  json.specimens specimen_url_template
  json.set! 'specimens.species', species_url_template unless expand?(:species, @inclusions)
  # json.set! 'species.characteristics', characteristic_url_template unless expand?(:characteristics, @inclusions)
  # json.set! 'species.characteristics.reference', reference_url_template unless expand?('characteristics.reference', @inclusions)
end unless @filter

json.specimens @specimens, partial: 'v1/specimens/specimen',
             collection: @specimens,
             as: :specimen,
             inclusions: @inclusions,
             fields: @fields,
             nested_fields: @nested_fields

json.meta do
  json.specimens do
    json.partial! 'v1/common/meta'
  end
end unless @filter