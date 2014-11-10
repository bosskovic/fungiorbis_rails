class Reference < ActiveRecord::Base
  include Uuid

  has_many :characteristics, dependent: :destroy

  validates :title, presence: true
  validates :isbn, uniqueness: true, if: 'isbn.present?'
  validates :url, format: { with: URI.regexp }, uniqueness: true, if: 'url.present?'

  self.per_page = 10
  self.max_per_page = 100

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
