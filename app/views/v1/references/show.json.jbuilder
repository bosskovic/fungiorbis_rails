json.status :success

json.links do
  json.references references_url_template
  json.set! 'references.characteristics', characteristic_url_template unless expand?(:characteristics, @inclusions)
  json.set! 'references.characteristics.species', species_url_template unless expand?('characteristics.species', @inclusions)
end

json.references do
  json.partial! 'v1/references/reference',
                reference: @reference,
                inclusions: @inclusions,
                fields: @fields,
                nested_fields: @nested_fields
end