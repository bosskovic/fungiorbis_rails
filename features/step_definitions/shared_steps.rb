And(/^response should include link to endpoint \/([^"]*)$/) do |resource_path|
  resource_name = resource_path.split('/').first
  expect(last_json).to be_json_eql(JsonSpec.remember("#{DOMAIN}/#{resource_path}".to_json)).at_path("links/#{resource_name}")
end

And(/^response should include (.*?) (#{CAPTURE_RESOURCE_NAME}) object with all public fields$/) do |scope, resource|
  if scope == 'first'
    record = Object.const_get(resource.capitalize).first
  else
    raise "unknown scope: #{scope}"
  end

  json_object = JSON.parse(last_json)[resource.pluralize]

  (public_species_fields-['id']).each do |field|
    my_value = json_object[field]
    expect(record.send(field.underscore.to_sym)).to eq my_value
  end
end
