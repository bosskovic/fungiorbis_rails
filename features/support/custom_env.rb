require 'json_spec/cucumber'
require 'camel_case'

include CamelCase

#For json_spec
def last_json
  last_response.body
end

def resource_hash_from_request(model)
  request = JSON.parse(last_request.body.entries.first)

  hash = request[model.to_s.pluralize] || request[model.to_s]

  keys_to_underscore hash, output: 'symbols'
end

def resource_from_request(model)
  attributes = resource_hash_from_request(model)

  keys_for_removal = []

  case model
    when :user
      keys_for_removal = [:password, :password_confirmation]
    when :species
  end

  remove_keys_from_hash!(attributes, keys_for_removal)

  Object.const_get(model.capitalize).send(:where, attributes).first
end

def remove_keys_from_hash!(hash, keys)
  keys.each { |key| hash.tap { |h| h.delete(key) } }
end

Before do
  DatabaseCleaner.start
end

After do
  DatabaseCleaner.clean
end
