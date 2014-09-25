FactoryGirl.define do

  factory :species do |s|
    s.name { Faker::Name.last_name }
    s.genus { Faker::Name.last_name }
    s.familia { Faker::Name.last_name }
    s.ordo { Faker::Name.last_name }
    s.subclassis { Faker::Name.last_name }
    s.classis { Faker::Name.last_name }
    s.subphylum { Faker::Name.last_name }
    s.phylum { Faker::Name.last_name }
    s.growth_type { (Species::GROWTH_TYPES + [nil]).sample }
    s.nutritive_group { (Species::NUTRITIVE_GROUPS + [nil]).sample }
  end

  factory :species_with_characteristics, parent: :species do |species|
    after(:create) do |s|
      (1 + rand(3)).times{ create(:characteristic, species: s)}
    end
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
