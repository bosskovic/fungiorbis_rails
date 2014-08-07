class User < ActiveRecord::Base
end

# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  email                :string(255)
#  username             :string(255)
#  first_name           :string(255)
#  last_name            :string(255)
#  title                :string(255)
#  role                 :string(255)
#  institution          :string(255)
#  phone                :string(255)
#  password             :string(255)
#  authentication_token :string(255)
#  created_at           :datetime
#  updated_at           :datetime
#
