json.status :success

json.links do
  json.characteristics characteristic_url_template
  json.set! 'characteristics.reference', reference_url_template unless expand?(:reference, @inclusions)
  json.set! 'characteristics.species', species_url_template unless expand?(:species, @inclusions)
end

json.characteristics @characteristics, partial: 'v1/characteristics/characteristic',
                     collection: @characteristics,
                     as: :characteristic,
                     inclusions: @inclusions,
                     fields: @fields,
                     nested_fields: @nested_fields

json.meta do
  json.characteristics do
    json.partial! 'v1/common/meta'
  end
end