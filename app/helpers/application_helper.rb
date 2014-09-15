require 'fungiorbis/camel_case'
module ApplicationHelper
  include Fungiorbis::CamelCase

  def expand?(field, options)
    options[:expand] && options[:expand].include?(field)
  end
end
