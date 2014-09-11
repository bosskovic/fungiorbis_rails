module SpeciesHelper

def public_species_fields
  @public_species_fields ||= ([:id] + V1::SpeciesController::PUBLIC_FIELDS).map { |f| f.to_s }
end

end

World(SpeciesHelper)