Given(/^there are (\d+) species$/) do |number_of_species|
  FactoryGirl.create_list(:species, number_of_species.to_i)
end

And(/^the species array should include objects with fields: (#{CAPTURE_SPECIES_FIELDS})$/) do |fields|
  expect(JSON.parse(last_json)['species'].first.keys).to match_array public_species_fields
end