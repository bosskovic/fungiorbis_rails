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
        last_json.should be_json_eql(JsonSpec.remember(200)).at_path('status')
        last_json.should be_json_eql(JsonSpec.remember(true)).at_path('success')
      when 'UNPROCESSABLE'
        expect(last_response.status).to eq 422
        last_json.should be_json_eql(JsonSpec.remember(422)).at_path('status')
        last_json.should be_json_eql(JsonSpec.remember(false)).at_path('success')
      when 'FORBIDDEN'
        expect(last_response.status).to eq 403
        last_json.should be_json_eql(JsonSpec.remember(403)).at_path('status')
        last_json.should be_json_eql(JsonSpec.remember(false)).at_path('success')
      when 'UNAUTHORIZED'
        expect(last_response.status).to eq 401
        last_json.should be_json_eql(JsonSpec.remember(401)).at_path('status')
        last_json.should be_json_eql(JsonSpec.remember(false)).at_path('success')
      when 'CREATED'
        expect(last_response.status).to eq 201
        last_json.should be_json_eql(JsonSpec.remember(201)).at_path('status')
        last_json.should be_json_eql(JsonSpec.remember(true)).at_path('success')
      else
        raise 'unknown status'
    end

  rescue RSpec::Expectations::ExpectationNotMetError => e
    puts 'Response body:'
    puts last_response.body
    raise e
  end
end

And(/^the (?:JSON|json)(?: response)? should be$/) do |table|
  table.hashes.first.each do |key, value|
    negation = value.include? 'not'
    value = value.split(' ').last if negation

    if %w(string array boolean object).include? value
      if negation
        last_json.should_not have_json_type(value).at_path(key)
      else
        last_json.should have_json_type(value).at_path(key)
      end
    else
      if negation
        last_json.should_not be_json_eql(JsonSpec.remember(value)).at_path(key)
      else
        last_json.should be_json_eql(JsonSpec.remember(value)).at_path(key)
      end
    end
  end
end