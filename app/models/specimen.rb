class Specimen < ActiveRecord::Base
  include Uuid

  PER_PAGE = 10
  MAX_PER_PAGE = 100

  belongs_to :species
  belongs_to :location
  belongs_to :legator, class_name: 'User'
  belongs_to :determinator, class_name: 'User'
end

# == Schema Information
#
# Table name: specimen
#
#  id                :integer          not null, primary key
#  species_id        :integer          not null
#  location_id       :integer          not null
#  legator_id        :integer          not null
#  legator_text      :string(255)
#  determinator_id   :integer
#  determinator_text :string(255)
#  habitats          :text
#  substrates        :text
#  date              :date             not null
#  quantity          :text
#  growth_type       :text
#  comment           :text
#  approved          :boolean
#  uuid              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#
# Indexes
#
#  index_specimen_on_determinator_id  (determinator_id)
#  index_specimen_on_legator_id       (legator_id)
#  index_specimen_on_location_id      (location_id)
#  index_specimen_on_species_id       (species_id)
#  index_specimen_on_uuid             (uuid) UNIQUE
#
