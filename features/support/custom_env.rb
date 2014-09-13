require 'json_spec/cucumber'
require 'camel_case'

include CamelCase

#For json_spec
def last_json
  last_response.body
end

def public_fields(model, options={})
  fields = [:id]
  case model.to_sym
    when :all
      fields += (V1::UsersController::PUBLIC_FIELDS +
          V1::UsersController::OPTIONAL_RESPONSE_FIELDS +
          V1::SpeciesController::PUBLIC_FIELDS).uniq
    when :user
      fields += V1::UsersController::PUBLIC_FIELDS
    when :species
      fields += V1::SpeciesController::PUBLIC_FIELDS
    else
      raise 'unknown model'
  end

  options[:output] == :symbol ? fields : fields.map { |f| f.to_s }
end

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
