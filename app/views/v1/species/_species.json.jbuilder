json.id species.uuid

species_fields = V1::SpeciesController::PUBLIC_FIELDS
json.extract! species, *species_fields