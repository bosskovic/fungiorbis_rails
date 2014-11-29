class User < ActiveRecord::Base

  include Uuid

  USER_ROLE = 'user'
  CONTRIBUTOR_ROLE = 'contributor'
  SUPERVISOR_ROLE = 'supervisor'
  ROLES = [USER_ROLE, CONTRIBUTOR_ROLE, SUPERVISOR_ROLE]

  PER_PAGE = 10
  MAX_PER_PAGE = 100

  acts_as_token_authenticatable

  devise :database_authenticatable, :registerable, :recoverable, :trackable, :validatable, :confirmable

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true, inclusion: {in: ROLES}

  # left up to Devise to validate
  # validates_presence_of :password_confirmation
  # validates_uniqueness_of :email, case_sensitive: true

  validate :password_complexity

  def full_name
    "#{self.first_name} #{self.last_name}"
  end

  def supervisor?
    self.role == SUPERVISOR_ROLE
  end

  def self.active
    where(:deactivated_at => nil)
  end

  def active?
    self.deactivated_at.nil?
  end

  def deactivate!
    self.update!(deactivated_at: DateTime.now)
  end

  def activate!
    self.update!(deactivated_at: nil)
  end

  private

  def password_complexity
    if password.present? && password_confirmed? and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W]).+/)
      errors.add :password, 'must include at least one of each: lowercase letter, uppercase letter, numeric digit, special character.'
    end
  end

  def password_confirmed?
    password_confirmation.nil? || password == password_confirmation
  end


end

# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      not null
#  encrypted_password     :string(255)
#  first_name             :string(255)      not null
#  last_name              :string(255)      not null
#  title                  :string(255)
#  role                   :string(255)      default("user"), not null
#  institution            :string(255)
#  phone                  :string(255)
#  uuid                   :string(255)
#  authentication_token   :string(255)
#  deactivated_at         :datetime
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  confirmation_token     :string(255)
#  confirmed_at           :datetime
#  confirmation_sent_at   :datetime
#  unconfirmed_email      :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#
# Indexes
#
#  index_users_on_authentication_token  (authentication_token) UNIQUE
#  index_users_on_confirmation_token    (confirmation_token) UNIQUE
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_uuid                  (uuid) UNIQUE
#
