require 'yaml'
require 'fungiorbis/util'

module HabitatHelper
  extend ActiveSupport::Concern

  include Fungiorbis::Util

  HABITATS_FILE_PATH = 'config/locales/sr/habitats.yml'

  def all_habitat_keys(options={ output: :symbol })
    @all_habitats ||= options[:output] == :symbol ? elements_to_sym(habitats_hash.keys) : elements_to_str(habitats_hash.keys)
  end

  def subhabitat_keys(habitat_key)
    if habitats_hash[habitat_key.to_s]
      has_subhabitats?(habitat_key) ? habitats_hash[habitat_key.to_s]['subhabitat'].keys : nil
    else
      raise "Unknown habitat #{habitat_key}"
    end
  end

  def species_keys(species_group)
    if species_hash[species_group.to_s]
      elements_to_sym species_hash[species_group.to_s].keys
    else
      raise "Unknown species group #{species_group}"
    end
  end

  def allowed_species_groups(habitat_key, subhabitat_key=nil)
    raise "Unknown habitat #{habitat_key}" unless habitats_hash[habitat_key.to_s]

    if subhabitat_key
      raise "Habitat #{habitat_key} has no subhabitats" unless habitats_hash[habitat_key.to_s]['subhabitat']
      raise "Unknown subhabitat #{subhabitat_key}" unless habitats_hash[habitat_key.to_s]['subhabitat'][subhabitat_key.to_s]

      habitats_hash[habitat_key.to_s]['subhabitat'][subhabitat_key.to_s]['allowed_species_groups'] || []
    else
      habitats_hash[habitat_key.to_s]['allowed_species_groups'] || []
    end
  end

  def allowed_species(habitat, subhabitat=nil)
    allowed_species_groups(habitat, subhabitat).map { |species_group| species_keys(species_group) }.flatten
  end

  # @param [Hash] options
  # @option options [int] :number_of_habitats
  # @option options [boolean] :has_subhabitat
  # @option options [int] :number_of_species
  # @return [Array<Hash>]
  def random_habitats(options={})

    habitats_sample = options[:has_subhabitat] ?
        all_habitat_keys.select { |habitat_key| has_subhabitats?(habitat_key) } :
        all_habitat_keys

    habitats_sample = (habitats_sample+habitats_sample).flatten
    sample = options[:number_of_habitats] || 1 + rand(habitats_sample.length * 2)
    habitats_sample = Array(habitats_sample.sample(sample))

    habitats_sample.map! do |habitat|
      subhabitat = case options[:has_subhabitat]
                     when true
                       subhabitat_keys(habitat).sample
                     when false
                       nil
                     else
                       (Array(subhabitat_keys(habitat))+[nil]).sample
                   end

      all_available_species = allowed_species_groups(habitat, subhabitat).map { |species_group| species_keys(species_group) }.flatten

      species_sample = case
                         when options[:number_of_species].nil?
                           all_available_species.sample(all_available_species.length)
                         when options[:number_of_species].to_i < 1
                           nil
                         when options[:number_of_species].to_i > all_available_species.length
                           all_available_species
                         else
                           all_available_species.sample(options[:number_of_species].to_i)
                       end

      if subhabitat || species_sample
        { habitat => { subhabitat: subhabitat, species: Array(species_sample).compact }.delete_if { |k, v| v.nil? || v.empty? } }
      else
        habitat
      end
    end
    habitats_sample.uniq
  end

  def habitats_yaml(locale='sr')
    @habitats_yaml ||= YAML.load_file(HABITATS_FILE_PATH)[locale]
  end

  private

  def has_subhabitats?(habitat_key)
    habitats_hash[habitat_key.to_s]['subhabitat']
  end

  def habitats_hash
    habitats_yaml['habitats']
  end

  def species_hash
    habitats_yaml['species']
  end
end