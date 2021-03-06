Given(/^there (?:are|is) (\d+) (species|species with characteristics|reference|reference with characteristics)(?: records)?$/) do |number, model|
  model.gsub!(' ', '_')
  FactoryGirl.create_list(model.to_sym, number.to_i)
end

# TODO refactor ?
And(/^response should include link to endpoint \/([^"]*)$/) do |resource_path|
  if resource_path.include? 'characteristic'
    resource_name = 'characteristics'
  else
    resource_name = resource_path.split('/').first
  end

  expect(last_json).to be_json_eql(JsonSpec.remember("#{DOMAIN}/#{resource_path}".to_json)).at_path("links/#{resource_name}")
end

And(/^response should include\s?(.*?)? (user|species|reference|characteristic) object with all public fields(?: plus )?(#{CAPTURE_FIELDS})?$/) do |scope, model, additional_fields|
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

And(/^the (user|species|reference|characteristic) was(\snot)? (?:added to|updated in) the database$/) do |model, negation|
  record = resource_from_request(model.to_sym)

  if negation
    expect(record).to be_nil
  else
    expect(record).not_to be_nil
  end
end

# TODO refactor ?
When(/^I send a PATCH request (?:for|to) "([^"]*)" with (?:")?(all public fields|#{CAPTURE_FIELDS})(?:")? updating (?:last|a) (species|reference|characteristic)$/) do |path, fields, model|
  load_last_record(model)

  path.gsub!(':UUID', last_record.uuid)

  if model == 'characteristic'
    path.gsub!(':SPECIES_UUID', last_record.species.uuid)
  end

  if fields == 'all public fields'
    attributes = FactoryGirl.attributes_for(model.to_sym)
  else
    attributes = random_attributes_hash_for(fields)
  end

  json = { resource_name(model) => to_camel_case(attributes) }.to_json

  steps %{
    When I send a PATCH request to "#{path}" with the following json:
    """
    #{ json }
    """
  }
end

And(/^(?:")?(all public|#{CAPTURE_FIELDS})(?:")? fields of the last (species|reference|characteristic) were updated$/) do |fields, model|
  new_record = model_class(model).last

  fields = public_fields(model, output: :symbol) if fields == 'all public'
  fields = to_underscore(fields, output: :symbol) - [:id] - associations(model)

  case model.to_sym
    when :species
      fields -= [:synonyms, :growth_type, :nutritive_group]
    when :reference, :characteristic

    else
      raise "unsupported model #{model} for checking updated fields in last record"
  end

  sent_params = resource_hash_from_request(model)

  fields.each do |field|
    sent_value = sent_params[field]
    db_value = new_record.send(field)
    expect(sent_value).to eq(db_value), lambda { "expected #{field} to be #{db_value}, got #{sent_value}" }
  end
end

And(/^([^"]*) of (species) were( not)? changed$/) do |associations, model, negation|
  new_record = model_class(model).last
  associations = associations.is_a?(Array) ? to_underscore(associations, output: :symbol) : csv_string_to_array(associations, output: :symbol)
  associations.each do |association|
    if negation
      expect(new_record.send(association)).to eq last_record.send(association)
    else
      expect(new_record.send(association)).not_to eq last_record.send(association)
    end
  end
end

And(/^the (species|references|characteristics) array should include objects with all public fields$/) do |model|
  expect(resource_hash_from_response(model).first.keys - ['links']).to match_array public_fields(model.to_sym, output: :string)
end

When(/^I send a DELETE request (?:for|to) "([^"]*)" for (?:the last|a) (species|reference|characteristic)$/) do |path, model|
  load_last_record(model)

  path.gsub!(':UUID', last_record.uuid)
  path.gsub!(':SPECIES_UUID', last_record.species.uuid) if model == 'characteristic'

  steps %{ When I send a DELETE request to "#{path}" }
end

And(/^the last (species|reference|characteristic) was(\snot)? deleted$/) do |model, negation|
  if negation
    expect(last_record.reload).not_to be_nil
  else
    expect { last_record.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end
end

And(/^location header should include link to created (species|reference|characteristic)$/) do |model|
  record = model_class(model).last
  if model.to_s == 'characteristic'
    path = "#{DOMAIN}/species/#{record.species.uuid}/#{resource_name(model)}/#{record.uuid}"
  else
    path = "#{DOMAIN}/#{resource_name(model)}/#{record.uuid}"
  end
  expect(last_response.header['Location']).to eq path
end

And /^I send a GET request to "([^"]*)" for first (species|reference) in database$/ do |path, model|
  uuid = model_class(model).first.uuid
  path.gsub!(':UUID', uuid)
  @last_href = "#{DOMAIN}#{path}"
  get(path).inspect
end

And(/^the (reference|characteristic) id(s)? should be present in the links object$/) do |model, array|
  uuid = main_resource_links_object[model] || main_resource_links_object[model.pluralize]
  if array
    expect(uuid.class).to eq Array
    uuid = uuid.first
  end

  expect(uuid.class).to eq String
  expect(model_class(model).find_by_uuid(uuid)).not_to be_nil
end