module CommonHelper

  def last_href
    if @last_href.nil?
      raise '@last_href was not set'
    else
      @last_href
    end
  end

  def public_fields(model, options={})
    fields = [:id]
    case model.to_sym
      when :all
        fields += (V1::UsersController::PUBLIC_FIELDS + V1::SpeciesController::PUBLIC_FIELDS).uniq
      when :user
        fields += V1::UsersController::PUBLIC_FIELDS
      when :species
        fields += V1::SpeciesController::PUBLIC_FIELDS
      else
        raise 'unknown model'
    end

    options[:output] == :symbol ? fields : fields.map { |f| f.to_s }
  end

  def fields_string_to_array(fields, options={})
    fields.to_s.gsub('and', ',').split(',').map { |f| options[:output] == :symbol ? f.strip.to_sym : f.strip }
  end


  def correct_representation?(model, record, fields=nil)
    json_object = JSON.parse(last_json)[model.to_s.pluralize]

    fields = json_object.keys unless fields

    fields.each do |field|
      my_value = json_object[field]
      expect(record.send(field.underscore.to_sym)).to eq my_value
    end
  end


end

World(CommonHelper)