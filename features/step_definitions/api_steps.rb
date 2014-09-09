# Headers

Given /^I send and accept JSON$/ do
  header 'Accept', 'application/json'
  header 'Content-Type', 'application/json'
end

Given /^I send and accept JSON using version (\d+) of the (\w+) API$/ do |version, model|
  header 'Accept', "application/vnd.#{model}+json; version=#{version}"
  header 'Content-Type', 'application/json'
end

When(/^I authenticate via auth_token "([^"]*)" and email "([^"]*)" in header$/) do |auth_token, email|
  header('X-User-Email', email)
  header('X-User-Token', auth_token)
end


# Requests

# request with a table
When /^I send a (GET|POST|PUT|DELETE) request to "([^"]*)" with the object "([^"]*)" and the following fields:$/ do |request_type, path, object, fields|
  camelized_hash = {}
  fields.hashes.first.each do |key, value|
    camelized_hash[key.camelize(:lower)] = value
  end

  steps %{
    When I send a #{request_type} request to "#{path}" with the following json:
    """
    #{{ object => camelized_hash }.to_json}
    """
  }
end

# request with a json
When /^I send a (GET|POST|PUT|DELETE) request (?:for|to) "([^"]*)"(?: with the following json:)?$/ do |*args|
  request_type = args.shift
  path = args.shift
  input = args.shift

  request_opts = { method: request_type.downcase.to_sym }

  unless input.nil?
    if input.class == Cucumber::Ast::Table
      request_opts[:params] = input.rows_hash
    else
      request_opts[:input] = input
    end
  end

  @last_href = "http://example.org#{path}"

  request(path, request_opts).inspect
end


# Responses

Then /^show me the (unparsed)?\s?response$/ do |unparsed|
  if unparsed == 'unparsed'
    puts last_response.body
  elsif last_response.headers['Content-Type'] =~ /json/
    json_response = JSON.parse(last_response.body)
    puts JSON.pretty_generate(json_response)
  else
    puts last_response.headers
    puts last_response.body
  end
end

Then /^the response status should be "(#{CAPTURE_RECOGNIZED_STATUS})"$/ do |status|
  begin
    case status
      when 'OK'
        expect(last_response.status).to eq 200
        last_json.should be_json_eql(JsonSpec.remember('success'.to_json)).at_path('status')
      when 'UNPROCESSABLE'
        expect(last_response.status).to eq 422
        last_json.should be_json_eql(JsonSpec.remember('fail'.to_json)).at_path('status')
        last_json.should be_json_eql(JsonSpec.remember('422'.to_json)).at_path('errors/status')
        last_json.should be_json_eql(JsonSpec.remember(status.to_json)).at_path('errors/title')
        last_json.should have_json_type('array').at_path('errors/details')
      when 'NOT FOUND'
        expect(last_response.status).to eq 404
        last_json.should be_json_eql(JsonSpec.remember('fail'.to_json)).at_path('status')
        last_json.should be_json_eql(JsonSpec.remember('404'.to_json)).at_path('errors/status')
        last_json.should be_json_eql(JsonSpec.remember(status.to_json)).at_path('errors/title')
        last_json.should have_json_type('array').at_path('errors/details')
      when 'FORBIDDEN'
        expect(last_response.status).to eq 403
        last_json.should be_json_eql(JsonSpec.remember('fail'.to_json)).at_path('status')
        last_json.should be_json_eql(JsonSpec.remember('403'.to_json)).at_path('errors/status')
        last_json.should be_json_eql(JsonSpec.remember(status.to_json)).at_path('errors/title')
        last_json.should have_json_type('array').at_path('errors/details')
      when 'UNAUTHORIZED'
        expect(last_response.status).to eq 401
        last_json.should be_json_eql(JsonSpec.remember('fail'.to_json)).at_path('status')
        last_json.should be_json_eql(JsonSpec.remember('401'.to_json)).at_path('errors/status')
        last_json.should be_json_eql(JsonSpec.remember(status.to_json)).at_path('errors/title')
        last_json.should have_json_type('array').at_path('errors/details')
      when 'CREATED'
        expect(last_response.status).to eq 201
        expect(last_response.body.strip).to be_empty
      when 'NO CONTENT'
        expect(last_response.status).to eq 204
        expect(last_response.body.strip).to be_empty
      else
        raise 'unknown status'
    end

  rescue RSpec::Expectations::ExpectationNotMetError => e
    puts 'Response body:'
    puts last_response.body
    raise e
  end
end


And(/^the JSON response should be empty$/) do
  expect(last_json.strip).to be_empty
end