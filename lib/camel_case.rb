module CamelCase

  def to_underscore(object, options={})
    if object.is_a? String
      underscore object, %w(symbol symbols).include?(options[:output])
    elsif object.is_a? Symbol
      underscore object, !%w(string strings).include?(options[:output])
    elsif object.is_a? Array
      array_to_underscore object, options
    elsif object.is_a? Hash
      keys_to_underscore object, options
    else
      raise "The type #{object.class} is not supported for conversion to underscore"
    end
  end

  def to_camel_case(object, options={})
    if object.is_a? String
      camelize object, %w(symbol symbols).include?(options[:output])
    elsif object.is_a? Symbol
      camelize object, !%w(string strings).include?(options[:output])
    elsif object.is_a? Array
      array_to_camel_case object, options
    elsif object.is_a? Hash
      keys_to_camel_case object, options
    else
      raise "The type #{object.class} is not supported for conversion to camel case"
    end
  end

  private

  def underscore(term, term_to_symbol)
    new_term = term.to_s.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
        gsub(/([a-z\d])([A-Z])/, '\1_\2').
        tr('-', '_').
        downcase
    term_to_symbol ? new_term.to_sym : new_term
  end

  # activesupport-4.1.4/lib/active_support/core_ext/string/inflections.rb
  def camelize(term, term_to_symbol)
    string = term.to_s.sub(/^(?:(?=a)b(?=\b|[A-Z_])|\w)/) { $&.downcase }
    string.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
    string.gsub!('/', '::')
    term_to_symbol ? string.to_sym : string
  end

  def keys_to_underscore(params, options)
    key_to_symbol = key_to_symbol?(params, options)
    Hash[params.map { |key, value| [underscore(key, key_to_symbol), value] }]
  end

  def keys_to_camel_case(params, options)
    key_to_symbol = key_to_symbol?(params, options)
    Hash[params.map { |key, value| [camelize(key, key_to_symbol), value] }]
  end

  def array_to_underscore(array, options)
    element_to_symbol = element_to_symbol?(array, options)
    array.map { |e| underscore(e, element_to_symbol) }
  end

  def array_to_camel_case(array, options)
    element_to_symbol = element_to_symbol?(array, options)
    array.map { |e| camelize(e, element_to_symbol) }
  end

  def keys_are_symbols?(hash)
    hash.keys.first.is_a?(Symbol)
  end

  def key_to_symbol?(params, options)
    options[:output] == 'symbols' || options[:output].nil? && keys_are_symbols?(params)
  end

  def elements_are_symbols?(array)
    array.first.is_a?(Symbol)
  end

  def element_to_symbol?(array, options)
    options[:output] == 'symbols' || options[:output].nil? && elements_are_symbols?(array)
  end
end