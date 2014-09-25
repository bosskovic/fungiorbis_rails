module Fungiorbis
  module CamelCase

    # @param [Object] object
    # @param [Hash] options
    # @option options [Symbol/String] :output -> [:string, :strings, 'string', 'strings', :symbol, :symbols, 'symbol', 'symbols']
    # @return [Object]
    def to_underscore(object, options={})
      case object
        when String, Symbol
          underscore object, options
        when Array
          array_to_underscore object, options
        when Hash
          keys_to_underscore object, options
        else
          raise "The type #{object.class} is not supported for conversion to underscore"
      end
    end

    # @param [Object] object
    # @param [Hash] options
    # @option options [Symbol/String] :output -> [:string, :strings, 'string', 'strings', :symbol, :symbols, 'symbol', 'symbols']
    # @return [Object]
    def to_camel_case(object, options={})
      case object
        when String, Symbol
          camelize object, options
        when Array
          array_to_camel_case object, options
        when Hash
          keys_to_camel_case object, options
        else
          raise "The type #{object.class} is not supported for conversion to camel case"
      end
    end

    private

    def underscore(term, options)
      new_term = term.to_s.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2').
          gsub(/([a-z\d])([A-Z])/, '\1_\2').
          tr('-', '_').
          downcase
      term_to_symbol?(term, options) ? new_term.to_sym : new_term
    end

    # activesupport-4.1.4/lib/active_support/core_ext/string/inflections.rb
    def camelize(term, options)
      new_term = term.to_s.sub(/^(?:(?=a)b(?=\b|[A-Z_])|\w)/) { $&.downcase }
      new_term.gsub!(/(?:_|(\/))([a-z\d]*)/i) { "#{$1}#{$2.capitalize}" }
      new_term.gsub!('/', '::')
      term_to_symbol?(term, options) ? new_term.to_sym : new_term
    end

    def keys_to_underscore(hash, options)
      Hash[hash.map { |key, value| [underscore(key, options), value] }]
    end

    def keys_to_camel_case(hash, options)
      Hash[hash.map { |key, value| [camelize(key, options), value] }]
    end

    def array_to_underscore(array, options)
      array.map { |e| underscore(e, options) }
    end

    def array_to_camel_case(array, options)
      array.map { |e| camelize(e, options) }
    end

    def term_to_symbol?(term, options)
      string_not_requested = ![:string, :strings, 'string', 'strings'].include?(options[:output])
      symbol_requested = [:symbol, :symbols, 'symbol', 'symbols'].include?(options[:output])

      term.is_a?(Symbol) && string_not_requested || term.is_a?(String) && symbol_requested
    end
  end
end