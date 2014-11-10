module FieldSearchable
  extend ActiveSupport::Concern

  private

  def search_by_fields(fields)
    params.map { |key, value| { to_underscore(key).gsub('_uuid', '.id') => value } if fields.include?(key.to_sym) }.compact
  end
end