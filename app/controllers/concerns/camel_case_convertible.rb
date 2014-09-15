require 'fungiorbis/camel_case'
module CamelCaseConvertible
  extend ActiveSupport::Concern

  include Fungiorbis::CamelCase
end