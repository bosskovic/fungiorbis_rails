When(/^I send a POST request to "\/species\/:SPECIES_UUID\/characteristics" with ([\w\s-]*)(?: and ")?(#{CAPTURE_FIELDS})?(?:")?$/) do |situation, fields|
  species = Species.first
  reference = Reference.first
  params_hash = keys_to_camel_case(FactoryGirl.attributes_for(:characteristic, species: species, reference: reference), output: :symbol)

  params_hash[:referenceId] = reference.uuid

  case situation
    when 'all mandatory fields valid'
      params_hash.merge! random_attributes_hash_for(fields, hash_keys: :symbol) if fields
    when 'non-existing species uuid in request'
      species.uuid = 'xxx'
    when 'all mandatory fields missing'
      keys_for_removal = [:referenceId]
      remove_keys_from_hash!(params_hash, keys_for_removal)
    when 'incorrect habitat'
      params_hash[:habitats] = [{ocean: {}}]
    when 'incorrect subhabitat'
      key = params_hash[:habitats].first.keys.first
      params_hash[:habitats].first[key][:subhabitat] = :ocean
    when 'incorrect species'
      key = params_hash[:habitats].first.keys.first
      params_hash[:habitats].first[key][:species] = :dog
    else
      raise "unknown situation: #{situation}"
  end

  params_json = { :characteristics => params_hash }.to_json

  steps %{
    When I send a POST request to "/species/#{species.uuid}/characteristics" with the following json:
    """
    #{params_json}
    """
  }
end


And /^I send a GET request to "(.*?)" for first species and first characteristic in database$/ do |path|
  characteristic = Characteristic.includes(:species).first
  path.gsub!(':SPECIES_UUID', characteristic.species.uuid).gsub!(':UUID', characteristic.uuid)
  @last_href = "#{DOMAIN}#{path}"
  get(path).inspect
end


And /^I send a GET request to \/species\/:SPECIES_UUID\/characteristics$/ do
  path = '/species/:SPECIES_UUID/characteristics'
  characteristic = Characteristic.includes(:species).first
  path.gsub!(':SPECIES_UUID', characteristic.species.uuid)
  @last_href = "#{DOMAIN}#{path}"
  get(path).inspect
end

When(/^I send a PATCH request (?:for|to) "\/species\/:SPECIES_UUID\/characteristics\/:UUID" \(last characteristic\) with (.*?)$/) do |situation|
  load_last_record(:characteristic)

  species_uuid = last_record.species.uuid
  characteristic_uuid = last_record.uuid
  params_hash = keys_to_camel_case(FactoryGirl.attributes_for(:characteristic), output: :symbol)

  case situation
    when 'non-existing species uuid in request'
      species_uuid = 'xxx'
    when 'non-existing characteristic uuid in request'
      characteristic_uuid = 'yyy'
    when 'incorrect habitat'
      params_hash[:habitats] = [{ocean: {}}]
    when 'incorrect subhabitat'
      key = params_hash[:habitats].first.keys.first
      params_hash[:habitats].first[key][:subhabitat] = :ocean
    when 'incorrect species'
      key = params_hash[:habitats].first.keys.first
      params_hash[:habitats].first[key][:species] = :dog
    else
      raise "unknown situation: #{situation}"
  end

  path = "/species/#{species_uuid}/characteristics/#{characteristic_uuid}"
  json = { characteristics: params_hash }.to_json

  steps %{
    When I send a PATCH request to "#{path}" with the following json:
    """
    #{ json }
    """
  }
end