require 'fungiorbis/factory'
module ControllerHelper
  include Fungiorbis::Factory

  def json
    @json ||= JSON.parse(response.body)
  end

  def has_updated_attributes(object_hash, record)
    record.reload

    object_hash.each_key do |key|
      snake_key = key.to_s.underscore.to_sym
      expect(record[snake_key]).to eq object_hash[key]
    end
  end

  def has_all_fields(response_hash, record, public_fields, optional_fields = [])
    expect(record).not_to be_nil
    record.reload

    public_fields.each do |field|
      unless record.is_a?(Species) && field == :characteristics
        expect(response_hash[field.to_s]).to eq record.send(field.to_s.underscore.to_sym)
      end
    end

    expect(response_hash['id']).to eq record.uuid

    intersection = optional_fields.map { |f| f.to_s } & response_hash.keys
    # +1 is for id
    expect(response_hash.keys.length).to eq public_fields.length + intersection.length + 1
  end



end
