module CommonHelper
  include Fungiorbis::Factory

  def last_href
    if @last_href.nil?
      raise '@last_href was not set'
    else
      @last_href
    end
  end


  def resource_hash_from_response(model)
    JSON.parse(last_json)[resource_name(model)]
  end

  def correct_representation?(model, record, fields=nil)
    json_object = resource_hash_from_response(model)

    fields = json_object.keys unless fields

    fields -= ['characteristics'] if model == 'species'

    fields.all? { |field| record.send(field.underscore.to_sym) == json_object[field] }
  end

  def resource_from_request(model)
    attributes = resource_hash_from_request(model)

    keys_for_removal = [:created_at, :updated_at]

    case model
      when :user
        keys_for_removal += [:password, :password_confirmation]
      when :species, :reference
      else
        raise "unknown model #{model} for resource from request"
    end

    remove_keys_from_hash!(attributes, keys_for_removal)

    model_class(model).send(:where, attributes).first
  end


  def model_class(model)
    Object.const_get(model.to_s.capitalize)
  end

  def resource_name(model)
    model.to_s.pluralize
  end

  def load_last_record(model)
    @last_record = model_class(model).last
  end

  def last_record
    raise 'last record is nil' unless @last_record
    @last_record
  end

  private

  def resource_hash_from_request(model)
    request = JSON.parse(last_request.body.entries.first)

    hash = request[resource_name(model)] || request[model.to_s]

    to_underscore hash, output: 'symbols'
  end

end

World(CommonHelper)