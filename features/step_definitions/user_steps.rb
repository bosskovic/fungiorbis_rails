# Authentication steps

When (/^I authenticate as (user|contributor|supervisor|unknown user)$/) do |user_type|
  if user_type == :unknown_user
    token = SecureRandom.hex
    email = Faker::Internet.email
  else
    @authenticated_user = find_user_by_type(user_type)
    token = @authenticated_user.authentication_token
    email = @authenticated_user.email
  end

  steps %{
    When I authenticate via auth_token "#{token}" and email "#{email}" in header
  }
end

When (/^I authenticate with incorrect token$/) do
  token = SecureRandom.hex
  email = find_user_by_type(:any_user)

  steps %{
    When I authenticate via auth_token "#{token}" and email "#{email}" in header
  }
end

And(/^the authentication token should (not\s)?have changed$/) do |negation|
  if negation
    expect(User.first.authentication_token).to eq users[:user][:authentication_token]
  else
    expect(User.first.authentication_token).not_to eq users[:user][:authentication_token]
  end
end


# seeding

# creates one or more users of specified type
Given(/^there (?:is a)?(?:are users)?(?::)? (#{CAPTURE_USER_TYPES})$/) do |user_types|
  Array(user_types).each { |type| create_user_by_type type }
end


# lookup

And(/^the users array should include my user with (.*?)$/) do |fields|
  user_json = JSON.parse(last_json)['users'].select { |user| user['email'] == @authenticated_user[:email] }.first.to_json
  compare_json_with_user(user_json, @authenticated_user, fields)
end

And(/^response should include(.*?)? user fields(?::)? (#{CAPTURE_USER_FIELDS})$/) do |scope, fields|
  user = scope && scope.match('my') ? @authenticated_user : find_user_by_type(:other_user)
  compare_json_with_user(last_json, user, fields)
end


# requests

# request for user show for specified user type
And /^I send a GET request to "#{USER_URL}" for (#{CAPTURE_USER_TYPES})$/ do |user_type|
  uuid = find_user_by_type(user_type).uuid
  path = USER_URL.gsub('\\', '').gsub(':UUID', uuid)
  @last_href = "#{DOMAIN}#{path}"
  get(path).inspect
end

# sign in request
When (/^I send a POST request to "\/users\/sign_in" with (?:my)?(incorrect)? credentials( and incorrect password)?$/) do |incorrect_credentials, incorrect_password|
  email = incorrect_credentials ? Faker::Internet.email : users[:user][:email]
  password = incorrect_credentials || incorrect_password ? '123' : users[:user][:password]

  steps %{
    When I send a POST request to "/users/sign_in" with the object "user" and the following fields:
      | email     | password    |
      | #{email}  | #{password} |
  }
end

When(/^I send a GET request to "#{USER_CONFIRMATION_URL}" with my confirmation token$/) do
  token = users[selected_users_type][:confirmation_token]
  path = USER_CONFIRMATION_URL.gsub('\\', '').gsub(':CONFIRMATION_TOKEN', token)
  @last_href = "#{DOMAIN}#{path}"
  r = get(path).inspect
  @authenticated_user = selected_user
  r
end

# sign up request
When(/^I send a POST request to "\/users" with firstName, lastName, email(?:,|\sand) password (?:and\s)?([\w\s]*)$/) do |situation|
  attributes = random_user_attributes :user

  params_hash = { firstName: attributes[:first_name],
                  lastName: attributes[:last_name],
                  email: attributes[:email],
                  password: attributes[:password],
                  passwordConfirmation: attributes[:password_confirmation] }

  case situation
    when 'no passwordConfirmation'
      params_hash.except!(:passwordConfirmation)
    when 'passwordConfirmation that does not match'
      params_hash[:passwordConfirmation] = 'Aa1!abab'
    when 'too short'
      params_hash[:password] = 'Aa1!'
      params_hash[:passwordConfirmation] = 'Aa1!'
    when 'too simple'
      params_hash[:password] = '12345678'
      params_hash[:passwordConfirmation] = '12345678'
    when 'passwordConfirmation where posted email already exists in the database'
      params_hash[:email] = find_user_by_type(:any_user)[:email]
    else
      raise 'unknown case' unless situation == 'matching passwordConfirmation'
  end

  params_json = { :user => params_hash }.to_json

  steps %{
    When I send a POST request to "/users" with the following json:
    """
    #{params_json}
    """
  }
end

# sign up request
When(/^I send a POST request to "\/users" without mandatory fields$/) do
  steps %{
    When I send a POST request to "/users" with the following json:
    """
    #{ { :user => { :passwordConfirmation => 'some_string' } }.to_json }
    """
  }
end


# confirmation

And(/^my account should be confirmed$/) do
  expect(selected_user.confirmed_at).to be_nil
  selected_user.reload
  expect(selected_user.confirmed_at).not_to be_nil
end


# selects an existing user so that comparisons can be made at later time
Given(/^I am (?:an|a)? (#{CAPTURE_USER_TYPES})$/) do |user_type|
  @selected_user = find_user_by_type user_type
  @selected_users_type = user_type
end

And(/^the user was not (added to|duplicated in) the database$/) do |situation|
  if situation == 'added to'
    expect(User.count).to eq 0
  elsif situation == 'duplicated in'
    expect(User.count).to eq 1
  end
end

When(/^my user account is deactivated$/) do
  u = User.find_by_role(:user)
  u.deactivated_at = DateTime.now
  u.save!
end