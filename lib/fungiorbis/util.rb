module Fungiorbis
  module Util
    def remove_keys_from_hash!(hash, keys)
      keys.each { |key| hash.tap { |h| h.delete(key) } }
    end

    def keep_keys_in_hash!(hash, keys)
      keys_are_symbols = hash.keys.first.is_a?(Symbol)
      hash.each_key { |key| hash.tap { |h| h.delete(key) unless keys.include?(keys_are_symbols ? key.to_sym : key.to_s) } }
    end

    def csv_string_to_array(fields, options={})
      fields.to_s.gsub(' and ', ',').split(',').map { |f| options[:output] == :symbol ? f.strip.to_sym : f.strip }.reject { |f| f.empty? }
    end
  end
end