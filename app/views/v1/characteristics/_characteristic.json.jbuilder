json.id characteristic.uuid

characteristic_fields = to_underscore(fields)
json.extract! characteristic, *characteristic_fields

if expand?(:reference, inclusions)
  json.reference do
    json.partial! 'v1/references/reference', reference: characteristic.reference, fields: nested_fields['reference'][:fields], nested_fields: nil, inclusions: nil
  end
end

if expand?(:species, inclusions)
  json.species do
    json.partial! 'v1/species/species', species: characteristic.species, fields: nested_fields['species'][:fields], nested_fields: nil, inclusions: nil
  end
end

unless expand?(:reference, inclusions) && expand?(:species, inclusions)
  json.links do
    json.reference characteristic.reference.uuid unless expand?(:reference, inclusions)
    json.species characteristic.species.uuid unless expand?(:species, inclusions)
  end
end