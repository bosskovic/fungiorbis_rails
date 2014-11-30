require_relative "#{Rails.root}/app/models/concerns/habitat_helper"
require_relative "#{Rails.root}/app/models/concerns/substrate_helper"
include HabitatHelper
include SubstrateHelper

FactoryGirl.define do
  factory :characteristic do
    association :species, factory: :species
    association :reference, factory: :reference
    # reference
    edible { [false, true, nil].sample }
    cultivated { [false, true, nil].sample }
    poisonous { [false, true, nil].sample }
    medicinal { [false, true, nil].sample }
    fruiting_body { {} }
    microscopy { {} }
    flesh { {} }
    chemistry { {} }
    note { {} }
    habitats { random_habitats }
    substrates { random_substrates }
  end
end

# == Schema Information
#
# Table name: characteristics
#
#  id            :integer          not null, primary key
#  reference_id  :integer          not null
#  species_id    :integer          not null
#  edible        :boolean
#  cultivated    :boolean
#  poisonous     :boolean
#  medicinal     :boolean
#  fruiting_body :text
#  microscopy    :text
#  flesh         :text
#  chemistry     :text
#  note          :text
#  habitats      :text
#  substrates    :text
#  uuid          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_characteristics_on_reference_id  (reference_id)
#  index_characteristics_on_species_id    (species_id)
#  index_characteristics_on_uuid          (uuid) UNIQUE
#
