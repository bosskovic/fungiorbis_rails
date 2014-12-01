module FieldSearchable
  extend ActiveSupport::Concern

  private

  def search_by_fields(fields)
    params.map do |key, value|
      value = true if value == 'true'
      value = false if value == 'false'

      if key.include? '.'
        # ?characteristic.edible=true
        pair = key.split '.'
        { to_underscore(pair[1]).gsub('_uuid', '.id') => value } if fields.include?(pair[0].to_sym)
      else
        # ?genus=amanita
        { to_underscore(key).gsub('_uuid', '.id') => value } if fields.include?(key.to_sym)
      end
    end.compact
  end
end