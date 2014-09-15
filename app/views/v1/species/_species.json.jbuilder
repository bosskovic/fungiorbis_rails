options ||= {}
json.id species.uuid

species_fields = V1::SpeciesController::PUBLIC_FIELDS.map { |f| f.to_s.underscore.to_sym }
json.extract! species, *species_fields

if expand? :characteristics, options
  json.characteristics species.characteristics, partial: 'v1/species/characteristic', collection: species.characteristics, as: :characteristic
else
  json.characteristics species.characteristics.map { |c| c.uuid }
end
