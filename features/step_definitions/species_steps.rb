Given(/^there are (\d+) species$/) do |number_of_species|
  FactoryGirl.create_list(:species, number_of_species.to_i)
end

And(/^the species array should include objects with all public fields$/) do
  expect(JSON.parse(last_json)['species'].first.keys).to match_array public_species_fields
end

And /^I send a GET request to "#{SPECIES_URL}" for first species in database$/ do
  uuid = Species.first.uuid
  path = SPECIES_URL.gsub('\\', '').gsub(':UUID', uuid)
  @last_href = "#{DOMAIN}#{path}"
  get(path).inspect
end