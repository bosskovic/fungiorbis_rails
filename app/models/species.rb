class Species < ActiveRecord::Base

  include Uuid

  GROWTH_TYPES = %w(single group)
  NUTRITIVE_GROUPS = %w(parasitic mycorrhizal saprotrophic parasitic-saprotrophic saprotrophic-parasitic)
  NAME_GENUS_VALIDATION_ERROR = '- genus combination must be unique'
  GROWTH_TYPE_VALIDATION_ERROR = "has to be one of: #{GROWTH_TYPES.inspect}"
  NUTRITIVE_GROUPS_VALIDATION_ERROR = "has to be one of: #{NUTRITIVE_GROUPS.inspect}"

  before_validation :generate_url

  validates :name, presence: true, uniqueness: { scope: :genus, case_sensitive: false, message: NAME_GENUS_VALIDATION_ERROR }
  validates :genus, presence: true
  validates :familia, presence: true
  validates :ordo, presence: true
  validates :subclassis, presence: true
  validates :classis, presence: true
  validates :subphylum, presence: true
  validates :phylum, presence: true
  # validates :url, presence: true, uniqueness: true

  validates :growth_type, allow_nil: true, inclusion: { in: GROWTH_TYPES, message: GROWTH_TYPE_VALIDATION_ERROR }
  validates :nutritive_group, allow_nil: true, inclusion: { in: NUTRITIVE_GROUPS, message: NUTRITIVE_GROUPS_VALIDATION_ERROR }

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
#  index_species_on_name_and_genus  (name,genus)
#  index_species_on_url             (url) UNIQUE
#  index_species_on_uuid            (uuid) UNIQUE
#
