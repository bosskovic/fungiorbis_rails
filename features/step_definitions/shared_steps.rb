Given(/^there (?:are|is) (\d+) (species|reference)(?: records)?$/) do |number, model|
  FactoryGirl.create_list(model.to_sym, number.to_i)
end


And(/^response should include link to endpoint \/([^"]*)$/) do |resource_path|
  resource_name = resource_path.split('/').first
  expect(last_json).to be_json_eql(JsonSpec.remember("#{DOMAIN}/#{resource_path}".to_json)).at_path("links/#{resource_name}")
end

And(/^response should include\s?(.*?)? (user|species|reference) object with all public fields(?: plus )?(#{CAPTURE_FIELDS})?$/) do |scope, model, additional_fields|
  case scope
    when 'first'
      record = model_class(model).first
    when 'last'
      record = model_class(model).last
    when 'my'
      case model
        when :user
          record = User.find_by_uuid(authenticated_user.uuid)
        else
          raise "undefined 'my' record for #{model}"
      end
    when ''
      case model
        when :user
          record = find_user_by_type(:other_user)
        else
          raise "undefined record for model #{model} and nil scope"
      end
    else
      raise "unknown scope: #{scope}"
  end

  fields = Array(additional_fields) + public_fields(model) - ['id']

  expect(correct_representation?(model, record, fields)).to be_truthy
end

And (/^response should include (user|species) object with fields: (.*?)$/) do |model, fields|
  resource_hash = resource_hash_from_response(model)
  expect(resource_hash.keys).to include(*fields)
end

And(/^the (user|species|reference) was(\snot)? (?:added to|updated in) the database$/) do |model, negation|
  record = resource_from_request(model.to_sym)

  if negation
    expect(record).to be_nil
  else
    expect(record).not_to be_nil
  end
end

When(/^I send a PATCH request (?:for|to) "([^"]*)" with (?:")?(all public fields|#{CAPTURE_FIELDS})(?:")? updating (?:last|a) (species|reference)$/) do |path, fields, model|
  load_last_record(model)

  path = path.gsub(':UUID', last_record.uuid)

  if fields == 'all public fields'
    attributes = FactoryGirl.attributes_for(model.to_sym)
  else
    attributes = random_attributes_hash_for fields
  end

  json = { resource_name(model) => to_camel_case(attributes) }.to_json

  steps %{
    When I send a PATCH request to "#{path}" with the following json:
    """
    #{ json }
    """
  }
end

And(/^(?:")?(all public|#{CAPTURE_FIELDS})(?:")? fields of the last (species|reference) were updated$/) do |fields, model|
  new_record = model_class(model).last

  fields = public_fields(model, output: :symbol) if fields == 'all public'
  fields = to_underscore(fields) - [:id]

  case model.to_sym
    when :species
      fields -= [:synonyms, :growth_type, :nutritive_group]
    when :reference

    else
      raise "unsupported model #{model} for checking updated fields in last record"
  end

  fields.each do |field|
    expect(new_record.send(field)).not_to eq last_record.send(field)
  end
end

And(/^the (species|references) array should include objects with all public fields$/) do |model|
  expect(resource_hash_from_response(model).first.keys).to match_array public_fields(model.to_sym, output: :string)
end

When(/^I send a DELETE request (?:for|to) "([^"]*)" for (?:the last|a) (species)$/) do |path, model|
  load_last_record(model)

  path = path.gsub(':UUID', last_record.uuid)

  steps %{ When I send a DELETE request to "#{path}" }
end

And(/^the last (species) was(\snot)? deleted$/) do |model, negation|
  if negation
    expect(last_record.reload).not_to be_nil
  else
    expect { last_record.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

And(/^location header should include link to created (species|reference)$/) do |model|
  record = model_class(model).last
  expect(last_response.header['Location']).to eq "#{DOMAIN}/#{resource_name(model)}/#{record.uuid}"
end

And /^I send a GET request to "([^"]*)" for first (species|reference) in database$/ do |path, model|
  uuid = model_class(model).first.uuid
  path.gsub!(':UUID', uuid)
  @last_href = "#{DOMAIN}#{path}"
  get(path).inspect
end
