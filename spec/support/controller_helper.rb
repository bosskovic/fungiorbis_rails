module ControllerHelper
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
      expect(response_hash[field.to_s]).to eq record.send(field.to_s.underscore.to_sym)
    end

    expect(response_hash['id']).to eq record.uuid

    intersection = optional_fields.map { |f| f.to_s } & response_hash.keys
    # +1 is for id
    expect(response_hash.keys.length).to eq public_fields.length + intersection.length + 1
  end

  def random_user_attribute(field, record=nil)
    case field
      when :firstName
        Faker::Name.first_name
      when :lastName
        Faker::Name.last_name
      when :title
        Faker::Name.prefix
      when :institution
        Faker::Company.name
      when :phone
        Faker::PhoneNumber.phone_number
      when :email
        Faker::Internet.email
      when :role
        record && record.role == 'user' ? 'supervisor' : 'user'
      when :updatedAt
        DateTime.now
      else
        raise 'unknown user field'
    end
  end

  def random_attributes_hash_for(fields, klass, selected_user=nil)
    params = {}
    fields.each { |field| params[field] = random_user_attribute field, selected_user }

    { klass.to_s.downcase.pluralize.to_sym => params }
  end

end
