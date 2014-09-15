Given(/^there (?:are|is) (\d+) species$/) do |number_of_species|
  FactoryGirl.create_list(:species, number_of_species.to_i)
end

And /^I send a GET request to "#{SPECIES_URL}" for first species in database$/ do
  uuid = Species.first.uuid
  path = SPECIES_URL.gsub('\\', '').gsub(':UUID', uuid)
  @last_href = "#{DOMAIN}#{path}"
  get(path).inspect
end

And(/^location header should include link to created species$/) do
  species = Species.last
  expect(last_response.header['Location']).to eq "#{DOMAIN}/species/#{species.uuid}"
end

When(/^I send a POST request to "\/species" with ([\w\s-]*)(?: and ")?(#{CAPTURE_FIELDS})?(?:")?$/) do |situation, fields|
  params_hash = keys_to_camel_case(FactoryGirl.attributes_for(:species), output: 'symbols')

  case situation
    when 'all mandatory fields valid'
      params_hash.merge! random_attributes_hash_for(fields, hash_keys: :symbol) if fields
    when 'all mandatory fields missing'
      keys_for_removal = [:name, :genus, :familia, :ordo, :subclassis, :classis, :subphylum, :phylum]
      remove_keys_from_hash!(params_hash, keys_for_removal)
    when 'name-genus not unique'
      species = FactoryGirl.create(:species)
      params_hash[:name] = species[:name]
      params_hash[:genus] = species[:genus]
    when 'incorrect value for growthType'
      params_hash[:growthType] = 'abc'
    when 'incorrect value for nutritiveGroup'
      params_hash[:nutritiveGroup] = 'abc'
    else
      raise "unknown situation: #{situation}"
  end

  params_json = { :species => params_hash }.to_json

  steps %{
    When I send a POST request to "/species" with the following json:
    """
    #{params_json}
    """
  }
end

When(/^I send a PATCH request (?:for|to) "\/species\/:UUID" \(last species\) with (.*?)$/) do |situation|
  load_last_record(:species)

  params_hash = keys_to_camel_case(FactoryGirl.attributes_for(:species), output: 'symbols')

  case situation
    when 'name-genus not unique'
      species = FactoryGirl.create(:species)
      params_hash[:name] = species[:name]
      params_hash[:genus] = species[:genus]
    when 'incorrect value for growthType'
      params_hash[:growthType] = 'abc'
    when 'incorrect value for nutritiveGroup'
      params_hash[:nutritiveGroup] = 'abc'
    when 'all mandatory fields removed'
      [:name, :genus, :familia, :ordo, :subclassis, :classis, :subphylum, :phylum].each do |field|
        params_hash[field] = nil
      end
    else
      raise 'unknown situation'
  end

  path = "/species/#{last_record.uuid}"
  json = { species: params_hash }.to_json

  steps %{
    When I send a PATCH request to "#{path}" with the following json:
    """
    #{ json }
    """
  }
end
