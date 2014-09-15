require 'rails_helper'

RSpec.describe Species, :type => :model do
  subject { FactoryGirl.create(:species) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:genus) }
    it { is_expected.to validate_presence_of(:familia) }
    it { is_expected.to validate_presence_of(:ordo) }
    it { is_expected.to validate_presence_of(:subclassis) }
    it { is_expected.to validate_presence_of(:classis) }
    it { is_expected.to validate_presence_of(:subphylum) }
    it { is_expected.to validate_presence_of(:phylum) }

    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:genus).with_message(Species::NAME_GENUS_VALIDATION_ERROR) }

    it { is_expected.to ensure_inclusion_of(:nutritive_group).in_array(Species::NUTRITIVE_GROUPS) }
    it { is_expected.to ensure_inclusion_of(:growth_type).in_array(Species::GROWTH_TYPES) }
  end

end

# == Schema Information
#
# Table name: species
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  genus           :string(255)      not null
#  familia         :string(255)      not null
#  ordo            :string(255)      not null
#  subclassis      :string(255)      not null
#  classis         :string(255)      not null
#  subphylum       :string(255)      not null
#  phylum          :string(255)      not null
#  synonyms        :text
#  growth_type     :string(255)
#  nutritive_group :string(255)
#  url             :string(255)
#  uuid            :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#
# Indexes
#
#  index_species_on_name_and_genus  (name,genus)
#  index_species_on_url             (url) UNIQUE
#  index_species_on_uuid            (uuid) UNIQUE
#
