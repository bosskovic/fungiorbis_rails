require 'json_spec/cucumber'
require 'fungiorbis/camel_case'
require 'fungiorbis/util'
require 'fungiorbis/factory'

include Fungiorbis::CamelCase
include Fungiorbis::Util

#For json_spec
def last_json
  last_response.body
end


# @param [String] model (resource name)
# @param [Hash] options
# @option options [Symbol] :output (:symbol for array of symbols)
# @option options [Boolean] :include_optional
def public_fields(model, options={})
  fields = [:id]
  case model.to_sym
    when :all
      fields += V1::UsersController::PUBLIC_FIELDS
      fields += V1::UsersController::OPTIONAL_RESPONSE_FIELDS if options[:include_optional]
      fields += V1::SpeciesController::PUBLIC_FIELDS
      fields += V1::ReferencesController::PUBLIC_FIELDS
    when :user
      fields += V1::UsersController::PUBLIC_FIELDS
      fields += V1::UsersController::OPTIONAL_RESPONSE_FIELDS if options[:include_optional]
    when :species
      fields += V1::SpeciesController::PUBLIC_FIELDS
    when :reference, :references
      fields += V1::ReferencesController::PUBLIC_FIELDS
    else
      raise "unknown model #{model} for public fields"
  end

  options[:output] == :symbol ? fields : fields.map { |f| f.to_s }
end


Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
