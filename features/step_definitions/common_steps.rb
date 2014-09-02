And(/^the response should include last href$/) do
  expect(last_json).to be_json_eql(JsonSpec.remember(last_href.to_json)).at_path('href')
end