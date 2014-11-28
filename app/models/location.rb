class Location < ActiveRecord::Base
  include Uuid

  PER_PAGE = 10
  MAX_PER_PAGE = 100

  has_many :specimens, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :utm, presence: true
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
