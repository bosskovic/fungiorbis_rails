require 'fungiorbis/util'

module FieldSelectable
  extend ActiveSupport::Concern

  private

  NESTED_FIELD_KEY_REGEX = /(?<=^fields)\[(\w+)\](?:\[(\w+)\])?(?:\[(\w+)\])?/

  # if no fields param is specified, all public fields are included in the response; otherwise only listed fields are included
  # fields can be specified with a type: fields[TYPE]=f1,f2,f3...
  def set_fields
    action = action_name.to_sym
    @fields = select_fields('fields', default_fields(action))
    @nested_fields = process_nested_fields(action)
  end

  def default_fields(action)
    raise 'FieldSelectable::default_fields has to be overriden'
  end

  def default_nested_fields(action)
    raise 'FieldSelectable::default_nested_fields has to be overriden'
  end

  def select_fields(params_key, default_fields)
    params[params_key] ? params[params_key].split(',').select { |f| default_fields.include?(f.to_sym) } : default_fields
  end


  def process_nested_fields(action)
    result = default_nested_fields(action)

    default_nested_fields = default_nested_fields(action)

    params.keys.each do |param_key|
      matched_resources = param_key.match(NESTED_FIELD_KEY_REGEX).to_a.drop(1).compact.uniq

      node = result
      matched_resources.each do |resource|
        node[resource] ||= {}
        if resource == matched_resources.last
          default_fields = Fungiorbis::Util.hash_access(default_nested_fields, matched_resources.join('.nested_fields.'))[:fields]
          node[resource][:fields] = select_fields(param_key, default_fields)
        else
          node[resource][:nested_fields] ||= {}
          node = node[resource][:nested_fields]
        end
      end
    end

    result
  end
end