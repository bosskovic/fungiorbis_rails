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

  def has_all_fields(response_hash, record, public_fields)
    expect(record).not_to be_nil
    record.reload

    public_fields.each { |field| expect(response_hash[field.to_s]).to eq(record.send(field.to_s.underscore.to_sym)) }

    expect(response_hash['id']).to eq record.uuid
    missing_fields = elements_to_str(public_fields) - response_hash.keys
    expect(missing_fields).to be_empty, lambda { "expected response to contain all public fields; fields '#{missing_fields}' are missing." }
  end

  def has_all_links(json, resource_name, link_keys)
    links = json['links']
    response_links = json[resource_name].respond_to?(:first) ? json[resource_name].first['links'] : json[resource_name]['links']

    Array(link_keys).each do |inclusion|
      expect(links["#{resource_name}.#{inclusion}"]).not_to be_nil
    end

    expect(response_links.keys).to eq Array(link_keys)
  end
end
