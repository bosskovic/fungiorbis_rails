require 'yaml'
require 'fungiorbis/util'
module SubstrateHelper
  extend ActiveSupport::Concern

  include Fungiorbis::Util

  SUBSTRATES_FILE_PATH = 'config/locales/sr/substrates.yml'

  def all_substrate_keys(options={ output: :symbol })
    @all_substrates ||= options[:output] == :symbol ? elements_to_sym(substrates_hash.keys) : elements_to_str(substrates_hash.keys)
  end

  # @param [Hash] options
  # @option options [int] :number_of_substrates
  # @raise StandardError if number of substrates specified is out of range
  def random_substrates(options={})
    sample = (options[:number_of_substrates] || 1+rand(all_substrate_keys.length)).to_i

    raise 'number of substrates out of scope' unless (1..all_substrate_keys.length).include?(sample)

    elements_to_str Array(all_substrate_keys.sample(sample))
  end

  def substrates_yaml(locale='sr')
    @substrates_yaml ||= YAML.load_file(SUBSTRATES_FILE_PATH)[locale]
  end

  private

  def substrates_hash
    substrates_yaml['substrates']
  end
end