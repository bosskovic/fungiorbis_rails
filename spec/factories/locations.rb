FactoryGirl.define do
  factory :location do
    name Faker::Lorem.sentence
    utm %w(34TDR200 34TDR210 34TDQ209 34TDR210).sample
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
