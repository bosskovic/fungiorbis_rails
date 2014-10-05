require 'fungiorbis/camel_case'
module ApplicationHelper
  include Fungiorbis::CamelCase

  def expand?(field, inclusions)
    inclusions && inclusions.include?(field.to_s)
  end

  # Takes arrays of strings such as [ 'res1', 'res1.res2', 'res1.res2.res3', 'res2.res1', 'res3' ]
  # and returns only those that have parent resource equal to the one specified and non empty nested resources
  # For the given example, if the resource is 'res1', the resulting array is ['res2', 'res2.res3']
  # For the given example, if the resource is 'res3', the resulting array is empty
  def inclusions_for_nested_resource(resource, inclusions)
    Array(inclusions).map do |value|
      resources = value.split('.', 2)
      resources[0] == resource.to_s ? resources[1] : nil
    end.compact
  end

  private

end
