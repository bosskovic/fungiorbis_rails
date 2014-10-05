module Fungiorbis
  module Factory

    def random_attribute(field, object=nil)
      case field.to_sym
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
          object && object.is_a?(User) && object.role == 'user' ? 'supervisor' : 'user'
        when :updatedAt, :createdAt
          DateTime.yesterday
        when :familia
          loop do
            familia = Faker::Name.first_name
            break familia if Species.find_by_familia(familia).nil?
          end
        when :ordo
          loop do
            ordo = Faker::Name.first_name
            break ordo if Species.find_by_ordo(ordo).nil?
          end
        when :url
          loop do
            url = Faker::Internet.url
            break url
          end
        when :title
          Faker::Lorem.sentence
        when :characteristics
          FactoryGirl.attributes_for(:characteristic)
        when :edible
          [true, false].sample
        when :cultivated
          [true, false].sample
        else
          raise "unknown field #{field} for random attribute generation"
      end
    end

    # @param [Array] field_names; can be strings or symbols
    # @param [Hash] options
    # @option options [Symbol] :hash_keys (:symbol for array of symbols)
    # @option options [Symbol] :class, if present it will return the hash as a value of that pluralized key
    # @option options [Symbol] :object, if present may affect the generation of the attributes
    # @return [Hash]
    def random_attributes_hash_for(field_names, options={})
      key_to_symbol = options[:hash_keys] == :symbol || (field_names.first.is_a?(Symbol) && options[:hash_keys] != :string)
      params = Hash[field_names.map { |field| [key_to_symbol ? field.to_sym : field.to_s, random_attribute(field, options[:object])] }]

      options[:class].nil? ? params : { options[:class].to_s.downcase.pluralize.to_sym => params }
    end

  end
end