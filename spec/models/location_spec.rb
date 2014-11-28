require 'rails_helper'

RSpec.describe Location, :type => :model do
  subject { FactoryGirl.create(:location) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:utm) }
  end
end

# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  utm        :string(255)      not null
#  uuid       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_locations_on_uuid  (uuid) UNIQUE
#
