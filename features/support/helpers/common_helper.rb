module CommonHelper

  def last_href
    if @last_href.nil?
      raise '@last_href was not set'
    else
      @last_href
    end
  end


  def fields_string_to_array(fields, options={})
    fields.to_s.gsub('and', ',').split(',').map { |f| options[:output] == :symbol ? f.strip.to_sym : f.strip }
  end

  def resource_hash_from_response(model)
    JSON.parse(last_json)[model.to_s.pluralize]
  end

  def correct_representation?(model, record, fields=nil)
    json_object = resource_hash_from_response(model)

    fields = json_object.keys unless fields

    fields.all? { |field| record.send(field.underscore.to_sym) == json_object[field] }
  end

  def resource_from_request(model)
    attributes = resource_hash_from_request(model)

    keys_for_removal = []

    case model
      when :user
        keys_for_removal = [:password, :password_confirmation]
      when :species
      else
        raise "unknown model #{model} for resource from request"
    end

    remove_keys_from_hash!(attributes, keys_for_removal)

    Object.const_get(model.capitalize).send(:where, attributes).first
  end

  def remove_keys_from_hash!(hash, keys)
    keys.each { |key| hash.tap { |h| h.delete(key) } }
  end

  def keep_keys_in_hash!(hash, keys)
    hash.each_key { |key| hash.tap { |h| h.delete(key) unless keys.include?(key.to_s) } }
  end

  private

  def resource_hash_from_request(model)
    request = JSON.parse(last_request.body.entries.first)

    hash = request[model.to_s.pluralize] || request[model.to_s]

    to_underscore hash, output: 'symbols'
  end

end

World(CommonHelper)