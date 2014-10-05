json.id characteristic.uuid

characteristic_fields = to_underscore(fields)
json.extract! characteristic, *characteristic_fields

if expand?(:reference, inclusions)
  json.reference do
    json.partial! 'v1/references/reference', reference: characteristic.reference, fields: nested_fields['reference'][:fields], nested_fields: nil
  end
else
  json.links do
    json.reference characteristic.reference.uuid
  end
end