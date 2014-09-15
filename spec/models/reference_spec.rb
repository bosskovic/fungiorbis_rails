require 'rails_helper'

RSpec.describe Reference, :type => :model do
  subject { FactoryGirl.create(:reference) }

  it 'has a valid factory' do
    expect(subject).to be_valid
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }

    it { is_expected.to validate_uniqueness_of(:isbn) unless subject.isbn.nil? }

    it { is_expected.to validate_uniqueness_of(:url) unless subject.url.nil? }
    it { is_expected.to allow_value('http://www.some_site.com').for(:url) }
    it { is_expected.not_to allow_value('www.some_site.com').for(:url) }
  end

end

# == Schema Information
#
# Table name: references
#
#  id         :integer          not null, primary key
#  title      :string(255)      not null
#  authors    :string(255)
#  isbn       :string(255)
#  url        :string(255)
#  uuid       :string(255)
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_references_on_uuid  (uuid) UNIQUE
#
