require 'yaml'
require 'fungiorbis/util'
module Fungiorbis
  module SubstrateHelper
    include Fungiorbis::Util

    SUBSTRATES_FILE_PATH = 'config/locales/en/substrates.yml'

    def all_substrate_keys
      @all_substrates ||= elements_to_sym YAML.load_file(SUBSTRATES_FILE_PATH)['en']['substrates'].keys
    end

    # @param [Hash] options
    # @option options [int] :number_of_substrates
    # @raise StandardError if number of substrates specified is out of range
    def random_substrates(options={})
      sample = (options[:number_of_substrates] || all_substrate_keys.length).to_i

      raise 'number of substrates out of scope' unless (1..all_substrate_keys.length).include?(sample)

      elements_to_str Array(all_substrate_keys.sample(sample))
    end
  end
end
