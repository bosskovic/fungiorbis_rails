json.status :success unless @filter

json.links do
  json.references reference_url_template
  json.set! 'references.characteristics', characteristic_url_template unless expand?(:characteristics, @inclusions)
  json.set! 'references.characteristics.species', species_url_template unless expand?('characteristics.species', @inclusions)
end unless @filter

json.references @references, partial: 'v1/references/reference',
                collection: @references,
                as: :reference,
                inclusions: @inclusions,
                fields: @fields,
                nested_fields: @nested_fields

json.meta do
  json.references do
    json.partial! 'v1/common/meta'
  end
end unless @filter