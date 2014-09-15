class Characteristic < ActiveRecord::Base
  include Uuid

  belongs_to :species
  belongs_to :reference

  serialize :fruiting_body, Hash
  serialize :microscopy, Hash
  serialize :flesh, Hash
  serialize :chemistry, Hash
  serialize :note, Hash

  serialize :habitats, Array
  serialize :substratums, Array

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
#  substratums   :text
#  uuid          :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#
# Indexes
#
#  index_characteristics_on_uuid  (uuid) UNIQUE
#
