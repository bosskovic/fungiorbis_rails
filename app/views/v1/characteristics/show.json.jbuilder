json.status :success

json.links do
  json.characteristics characteristics_url_template
  json.set! 'characteristics.reference', reference_url_template unless expand?(:reference, @inclusions)
  json.set! 'characteristics.species', species_url_template unless expand?(:species, @inclusions)
end

json.characteristics do
  json.partial! 'v1/characteristics/characteristic',
                characteristic: @characteristic,
                inclusions: @inclusions,
                fields: @fields,
                nested_fields: @nested_fields
end