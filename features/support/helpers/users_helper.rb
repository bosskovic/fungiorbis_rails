module UserHelpers

  def find_user_by_type(user_type)
    if [:current_user, :authenticated_user].include? user_type
      @authenticated_user
    elsif user_type == :other_user
      if @authenticated_user
        User.where.not(email: @authenticated_user.email).first
      else
        User.first
      end
    elsif  [:user, :contributor, :supervisor].include? user_type
      User.find_by_role user_type.to_s
    elsif user_type == :any_user
      User.first
    elsif user_type == :unconfirmed_user
      User.where(confirmed_at: nil).first
    elsif user_type == :confirmed_user
      User.where.not(confirmed_at: nil).first
    elsif user_type == :deactivated_user
      User.where.not(deactivated_at: nil).first
    else
      nil
    end
  end

  def create_user_by_type(user_type)
    attributes = FactoryGirl.attributes_for([:contributor, :supervisor].include?(user_type) ? user_type : :user)

    u = User.create! attributes
    attributes[:authentication_token] = u.authentication_token

    if [:unconfirmed_user, :confirmed_user].include? user_type
      u.confirmed_at = nil if user_type == :unconfirmed_user
      conf_token = SecureRandom.hex
      u.confirmation_token = Devise.token_generator.digest(u, :confirmation_token, conf_token)
      u.save!

      attributes[:confirmation_token] = conf_token
    end

    u.deactivate! if user_type == :deactivated_user

    @users ||= {}
    @users[user_type] = attributes
  end


  def compare_json_with_user(json, user, fields, context = 'object')
    fields.each do |field|
      field.strip!

      negated = field.match /^no\s/
      if negated
        field = field.gsub(/^no\s/, '').strip
      end

      if field == 'authToken'
        my_value = user[:authentication_token]
      else
        my_value = user[field.underscore.to_sym]
      end

      my_value = my_value.nil? ? 'null' : my_value.to_json

      field = "users/#{field}" unless context == 'array'

      if negated
        expect(json).not_to include_json(field.to_json)
      else
        expect(json).to be_json_eql(JsonSpec.remember(my_value)).at_path(field)
      end
    end
  end


  def random_user_attribute(field, user=nil)
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
        user && user.role == 'user' ? :supervisor : :user
      when :updatedAt
        DateTime.now
      else
        raise 'unknown user field'
    end
  end

  def users
    if @users.nil?
      raise '@users is nil'
    else
      @users
    end
  end

  def selected_users_type
    if @selected_users_type.nil?
      raise '@selected_users_type is nil'
    else
      @selected_users_type
    end
  end

  def selected_user
    if @selected_user.nil?
      raise '@selected_user is nil'
    else
      @selected_user
    end
  end

  def authenticated_user
    if @authenticated_user.nil?
      raise '@authenticated_user is nil'
    else
      @authenticated_user
    end
  end

end

World(UserHelpers)