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

    def elements_to_sym(array)
      array.map { |e| e.to_sym }
    end

    def elements_to_str(array)
      array.map { |e| e.to_s }
    end

    def array_is_superset?(superset, array)
      superset.nil? && array.nil? || !superset.nil? && !array.nil? && array & superset == array
    end

    def hash_access(hash, path)
      path.split('.').each do |p|
        hash = hash[p.to_s] || hash[p.to_sym]
        break unless hash
      end
      hash
    end
  end
end