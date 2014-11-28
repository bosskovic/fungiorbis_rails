require 'rails_helper'

RSpec.describe Specimen, :type => :model do
  subject { FactoryGirl.create(:specimen) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end
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
#  note              :text
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
