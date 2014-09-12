class Species < ActiveRecord::Base

  include Uuid

  GROWTH_TYPES = %w(single group)
  NUTRITIVE_GROUPS = %w(parasitic mycorrhizal saprotrophic parasitic-saprotrophic saprotrophic-parasitic)

  before_validation :generate_url

  validates :name, presence: true
  validates :genus, presence: true
  validates :familia, presence: true
  validates :ordo, presence: true
  validates :subclassis, presence: true
  validates :classis, presence: true
  validates :subphylum, presence: true
  validates :phylum, presence: true
  validates :url, presence: true, uniqueness: true

  validates :growth_type, allow_nil: true, inclusion: {in: GROWTH_TYPES}
  validates :nutritive_group, allow_nil: true, inclusion: {in: NUTRITIVE_GROUPS}

  self.per_page = 10

  protected

  def generate_url
    self.url = "#{self.genus}-#{self.name}".strip.gsub(' ', '_').gsub('.', '').downcase
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
#  index_species_on_url  (url) UNIQUE
#
