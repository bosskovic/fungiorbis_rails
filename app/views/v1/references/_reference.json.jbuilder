json.id reference.uuid
json.fullTitle reference.full_title
reference_fields = to_underscore fields
json.extract! reference, *reference_fields

if expand? :characteristics, inclusions
  json.characteristics reference.characteristics,
                       partial: 'v1/characteristics/characteristic',
                       collection: reference.characteristics,
                       as: :characteristic,
                       inclusions: inclusions_for_nested_resource(:characteristics, inclusions),
                       fields: nested_fields['characteristics'][:fields],
                       nested_fields: nested_fields['characteristics'][:nested_fields]
else
  json.links do
    json.characteristics reference.characteristics.map { |c| c.uuid }
  end
end
