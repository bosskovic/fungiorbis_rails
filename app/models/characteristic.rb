class Characteristic < ActiveRecord::Base
  include Uuid
  include HabitatHelper
  include SubstrateHelper

  # HABITATS_VALIDATION_ERROR = "have to be included in: #{elements_to_str(all_habitat_keys)}"
  SUBHABITATS_VALIDATION_ERROR = 'must take subhabitats from the list for specific habitat'
  SPECIES_VALIDATION_ERROR = 'must take species from the list for specific habitat and subhabitat'
  # SUBSTRATES_VALIDATION_ERROR = "have to be included in: #{all_substrate_keys.inspect}"

  PER_PAGE = 10
  MAX_PER_PAGE = 100

  belongs_to :species
  belongs_to :reference

  serialize :fruiting_body, JSON
  serialize :microscopy, JSON
  serialize :flesh, JSON
  serialize :chemistry, JSON
  serialize :note, JSON

  serialize :habitats, JSON
  serialize :substrates, JSON

  validates :species_id, presence: true
  validates :reference_id, presence: true

  validate :habitats_array
  validate :substrates_array
  validate :localized_hashes

  private

  def localized_hashes
    locales = elements_to_str I18n.available_locales
    [:fruiting_body, :microscopy, :flesh, :chemistry, :note].each do |field|
      hash = self.send(field)
      unless hash.blank? || array_is_superset?(locales, hash.keys)
        errors.add field, "locale keys have to be included in #{locales}"
      end
    end
  end

  def habitats_array
    if habitats.is_a? Array
      habitats.each do |habitat|
        if habitat.keys.length > 1
          errors.add :habitats, 'incorrect habitats format'
          return false
        elsif all_habitat_keys(output: :string).include?(habitat.keys.first.to_s)
          habitat_key = habitat.keys.first.to_s
          habitat = habitat.values.first
          unless habitat.empty? || !habitat[:subhabitat]
            allowed_subhabitats = subhabitat_keys(habitat_key)
            unless array_is_superset?(allowed_subhabitats, Array(habitat[:subhabitat]))
              errors.add :habitats, SUBHABITATS_VALIDATION_ERROR
              return false
            end
          end
          unless habitat.empty? || !habitat[:species]
            allowed_species = elements_to_str(allowed_species(habitat_key, habitat[:subhabitat]))
            species = elements_to_str(Array(habitat[:species]))
            unless array_is_superset?(allowed_species, species)
              errors.add :habitats, SPECIES_VALIDATION_ERROR
              return false
            end
          end
        else
          errors.add :habitats, "have to be included in: #{elements_to_str(all_habitat_keys)}"
          return false
        end
      end
    else
      true
    end
  end

  def substrates_array
    if substrates.is_a? Array
      s = elements_to_str substrates
      unless array_is_superset?(all_substrate_keys(output: :string), s)
        errors.add :substrates, "have to be included in: #{all_substrate_keys.inspect}"
        false
      end
    else
      true
    end
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
