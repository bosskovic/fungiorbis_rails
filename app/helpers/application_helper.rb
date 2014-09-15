require 'fungiorbis/camel_case'
module ApplicationHelper
  include Fungiorbis::CamelCase

  # TODO check if this should be removed
  # def show_field?(fields, field)
  #   fields.blank? || fields.include?(field)
  # end
  #
  # def selective_fields(available_fields, selected_fields)
  #   available_fields.map { |f| f.to_sym if selected_fields.blank? || selected_fields.include?(f.camelize(:lower)) }.reject(&:nil?)
  # end
end
