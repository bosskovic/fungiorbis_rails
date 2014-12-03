json.id species.uuid
json.fullName species.full_name
json.image "/images/species/#{species.full_name.gsub(' ', '_')}.jpg" if FileTest.exist?("#{Rails.root}/public/images/species/#{species.full_name.gsub(' ', '_')}.jpg")
species_fields = to_underscore(fields)
json.extract! species, *species_fields

if expand?(:characteristics, inclusions)
  json.characteristics species.characteristics,
                       partial: 'v1/characteristics/characteristic',
                       collection: species.characteristics,
                       as: :characteristic,
                       inclusions: inclusions_for_nested_resource(:characteristics, inclusions),
                       fields: nested_fields['characteristics'][:fields],
                       nested_fields: nested_fields['characteristics'][:nested_fields]
else
  json.links do
    json.characteristics species.characteristics.map { |c| c.uuid }
  end
end
