FactoryGirl.define do
  factory :reference do
    title { Faker::Lorem.sentence }
    authors { Faker::Name.name }
    url { [Faker::Internet.url, nil].sample }
    isbn { [Faker::Code.isbn, nil].sample }
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
