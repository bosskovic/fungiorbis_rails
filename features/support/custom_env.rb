require 'json_spec/cucumber'

#For json_spec
def last_json
  last_response.body
end

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
