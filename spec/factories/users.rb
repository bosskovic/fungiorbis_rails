FactoryGirl.define do

  factory :user do |user|
    user.email { Faker::Internet.safe_email }
    user.password { "#{Forgery(:basic).password(at_least: 8)}Aa1!" }
    user.first_name { Faker::Name.first_name }
    user.last_name { Faker::Name.last_name }
    user.confirmed_at DateTime.now
    user.role User::USER_ROLE
    user.institution { Faker::Company.name }
    user.phone { Faker::PhoneNumber.phone_number }
  end

  factory :contributor, parent: :user do |user|
    user.role User::CONTRIBUTOR_ROLE
  end

  factory :supervisor, parent: :user do |user|
    user.role User::SUPERVISOR_ROLE
  end

  factory :deactivated_user, parent: :user do |user|
    after(:create) do |u|
      u.deactivate!
    end
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
