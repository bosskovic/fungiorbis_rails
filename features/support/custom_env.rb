require 'cucumber/api_steps'
require 'json_spec/cucumber'

#For json_spec
def last_json
  page.source
end

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
