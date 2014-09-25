# Authentication steps

When (/^I authenticate as (user|contributor|supervisor|unknown user|deactivated user)$/) do |user_type|
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
  user_json = resource_hash_from_response(:user).select { |user| user['email'] == @authenticated_user[:email] }.first.to_json
  compare_json_with_user(user_json, @authenticated_user, fields, 'array')
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
When (/^I send a POST request to "\/users\/sign_in" with (?:my)?(incorrect|no)? credentials( and incorrect password)?$/) do |incorrect_credentials, incorrect_password|
  if incorrect_credentials && incorrect_credentials == 'no'
    email = nil
    password = nil
  else
    email = incorrect_credentials ? Faker::Internet.email : users[:user][:email]
    password = incorrect_credentials || incorrect_password ? '123' : users[:user][:password]
  end

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
  params_hash = keys_to_camel_case(FactoryGirl.attributes_for(:user), output: :symbol)
  remove_keys_from_hash!(params_hash, [:confirmedAt])

  case situation
    when 'no passwordConfirmation'
    when 'passwordConfirmation that does not match'
          params_hash[:passwordConfirmation] = 'Aa1!abab'
    when 'too short'
      params_hash[:password] = 'Aa1!'
      params_hash[:passwordConfirmation] = 'Aa1!'
    when 'too simple'
      params_hash[:password] = '12345678'
      params_hash[:passwordConfirmation] = '12345678'
    when 'passwordConfirmation where posted email already exists in the database'
      params_hash[:passwordConfirmation] = params_hash[:password]
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

When(/^my user account is deactivated$/) do
  u = User.find_by_role(:user)
  u.deactivated_at = DateTime.now
  u.save!
end

And(/^user should be activated$/) do
  expect(authenticated_user.active?).to be_falsey
  expect(User.find_by_uuid(authenticated_user.uuid).active?).to be_truthy
end

And(/^location header should include link to created user$/) do
  user = find_user_by_type(:other_user)
  expect(last_response.header['Location']).to eq "#{DOMAIN}/users/#{user.uuid}"
end

And(/^I send a PATCH request (?:for|to) "([^"]*)" with updated fields "(#{CAPTURE_USER_FIELDS})" for (#{CAPTURE_USER_TYPES})$/) do |path, fields, user_type|
  @selected_user = find_user_by_type user_type
  path = path.gsub(':UUID', selected_user.uuid)

  params = {}
  fields.each do |field|
    field = field.strip.to_sym
    params[field] = random_attribute field, selected_user
  end

  json = { users: params }.to_json

  steps %{
    When I send a PATCH request to "#{path}" with the following json:
    """
    #{ json }
    """
  }
end

And(/^I send a blank PATCH request to "([^"]*)" for (#{CAPTURE_USER_TYPES})$/) do |path, user_type|
  @selected_user = find_user_by_type user_type
  path = path.gsub(':UUID', selected_user.uuid)
  steps %{
    When I send a PATCH request to "#{path}"
  }
end

And(/^user field(?:s)? "(#{CAPTURE_USER_FIELDS})" (?:were|was)( not)? updated$/) do |fields, negation|
  old_user_object = selected_user.dup
  new_user_object = User.find_by_uuid selected_user.uuid
  fields.each do |field|
    field = field.underscore.to_sym

    if negation
      expect(old_user_object.send(field)).to eq new_user_object.send(field)
    else
      expect(old_user_object.send(field)).not_to eq new_user_object.send(field)
    end
  end
end