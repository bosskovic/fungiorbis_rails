module Uuid
  extend ActiveSupport::Concern

  included do
    before_create :generate_uuid
  end

  protected

  def generate_uuid
    self.uuid = loop do
      # random_uuid = SecureRandom.urlsafe_base64(nil, false)
      random_uuid = SecureRandom.random_number(2147483647).to_s
      break random_uuid unless self.class.exists?(uuid: random_uuid)
    end
  end
end