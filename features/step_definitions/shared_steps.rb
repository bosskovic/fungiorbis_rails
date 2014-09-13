And(/^response should include link to endpoint \/([^"]*)$/) do |resource_path|
  resource_name = resource_path.split('/').first
  expect(last_json).to be_json_eql(JsonSpec.remember("#{DOMAIN}/#{resource_path}".to_json)).at_path("links/#{resource_name}")
end

And(/^response should include\s?(.*?)? (user|species) object with all public fields(?: plus )?(#{CAPTURE_FIELDS})?$/) do |scope, model, additional_fields|
  case scope
    when 'first'
      record = Object.const_get(model.capitalize).first
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


  json_object = JSON.parse(last_json)[model.to_s.pluralize]

  fields = Array(additional_fields) + public_fields(model) - ['id']

  fields.each do |field|
    my_value = json_object[field]
    expect(record.send(field.underscore.to_sym)).to eq my_value
  end
end

And (/^response should include (user|species) object with fields: (.*?)$/) do |model, fields|

end

And(/^the (user|species) was(\snot)? added to the database$/) do |model, negation|
  record = resource_from_request(model)

  if negation
    expect(record).to be_nil
  else
    expect(record).not_to be_nil
  end
end