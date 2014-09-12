json.id species.uuid

species_fields = V1::SpeciesController::PUBLIC_FIELDS.map { |f| f.to_s.underscore.to_sym }
json.extract! species, *species_fields