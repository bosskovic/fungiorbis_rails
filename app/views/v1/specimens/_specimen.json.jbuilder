json.id specimen.uuid
json.fullName specimen.species.full_name

specimen_fields = to_underscore(fields)
json.extract! specimen, *specimen_fields

json.dateFormatted specimen.date.strftime("%d.%m.%Y.")

json.species specimen.species
json.characteristics specimen.species.characteristics
json.location specimen.location
json.legator specimen.legator
json.determinator specimen.determinator


# if expand?(:species, inclusions)
#   json.species do
#     json.partial! 'v1/species/species', species: specimen.species, fields: V1::SpeciesController::PUBLIC_FIELDS, nested_fields: nil, inclusions: 'characteristics'
#   end

  # json.characteristics do
  #   json.partial! 'v1/characteristics/characteristic', characteristics: specimen.species.characteristics, fields: V1::CharacteristicsController::PUBLIC_FIELDS, nested_fields: nil, inclusions: nil
  # end
# end

# unless expand?(:species, inclusions)
#   json.links do
#     json.species specimen.species.uuid unless expand?(:species, inclusions)
#   end
# end
