module Filterable
  extend ActiveSupport::Concern

  private

  def filter_request?
    @filter = filtering_fields_defined? &&
        valid_filter_target_fields?(filter_options[:fields]) &&
        valid_fields?(filter_options[:fields], filter_options[:additional_fields])
  end

  def filtering_fields_defined?
    params[:filterTarget] && params[:fields] && params[:filterValue] && params[:filterValue].strip.length > 2
  end

  def filter_values
    params[:filterValue].strip.split(' ').map { |value| "%#{value}%" }
  end

  def filter_condition
    params[:filterTarget].split(',').map { |field| to_underscore(field) }.join(' LIKE :value OR ') + ' LIKE :value'
  end

  def filter_response_fields
    fields = params[:fields].gsub('id', 'uuid').split(',').map { |field| to_underscore(field) }
    if response_fields_replacements
      response_fields_replacements.each do |key, value|
        if fields.include? key
          fields.delete key
          fields += Array(value)
        end
      end
    end
    fields.join(',')
  end

  def valid_filter_target_fields?(fields)
    params[:filterTarget].split(',').all? { |field| fields.include? field.to_sym }
  end

  def valid_fields?(fields, additional_fields)
    fields += additional_fields if additional_fields
    params[:fields].split(',').all? { |field| fields.include? field.to_sym }
  end

  def filter_options
    raise 'Filterable::filter_options have to be overriden'
  end

  def response_fields_replacements
    nil
  end
end