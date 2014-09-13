require 'camel_case'
module CamelCaseConvertible
  extend ActiveSupport::Concern

  include CamelCase
end