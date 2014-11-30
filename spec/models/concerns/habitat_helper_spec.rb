require 'rails_helper'
require "#{Rails.root}/app/models/concerns/habitat_helper"

RSpec.describe HabitatHelper do

  include HabitatHelper

  describe '#all_habitat_keys' do
    specify { expect(all_habitat_keys.is_a?(Array)).to be_truthy }
  end

  describe '#subhabitat_keys' do
    context 'when habitat has subhabitats' do
      context 'with correct argument' do
        let(:habitat_key) { :forest }
        specify { expect(subhabitat_keys(habitat_key).is_a?(Array)).to be_truthy }
      end
    end

    context 'when habitat does not have subhabitats' do
      context 'with correct argument' do
        let(:habitat_key) { :meadow }
        specify { expect(subhabitat_keys(habitat_key)).to be_nil }
      end
    end

    context 'with incorrect argument' do
      let(:habitat_key) { :ocean }
      specify { expect { (subhabitat_keys(habitat_key)) }.to raise_error(StandardError) }
    end
  end

  describe '#species_keys' do
    context 'with correct argument' do
      let(:species_group) { :coniferous }
      specify { expect(species_keys(species_group).is_a?(Array)).to be_truthy }
    end

    context 'with incorrect argument' do
      let(:species_group) { :alien }
      specify { expect { (species_keys(species_group)) }.to raise_error(StandardError) }
    end
  end

  describe '#allowed_species_groups' do
    [nil, :coniferous].each do |subhabitat_key|
      context 'with correct arguments' do
        let(:habitat_key) { :forest }
        specify { expect(allowed_species_groups(habitat_key, subhabitat_key).is_a?(Array)).to be_truthy }
      end
    end

    context 'with incorrect habitat_key' do
      let(:habitat_key) { :ocean }
      specify { expect { (allowed_species_groups(habitat_key)) }.to raise_error(StandardError) }
    end

    context 'with incorrect subhabitat_key' do
      let(:habitat_key) { :forest }
      specify { expect { (allowed_species_groups(habitat_key, :alien)) }.to raise_error(StandardError) }
    end
  end

  describe '#allowed_species' do
    [nil, :coniferous, :mixed].each do |subhabitat_key|
      context 'with correct arguments' do
        let(:habitat_key) { :forest }
        specify { expect(allowed_species(habitat_key, subhabitat_key).is_a?(Array)).to be_truthy }
      end
    end
  end

  describe 'random_habitats' do
    context 'with no arguments' do
      specify { expect(random_habitats.is_a?(Array)).to be_truthy }
    end

    context 'options[:has_subhabitat]' do
      specify { expect(random_habitats(has_subhabitat: true).is_a?(Array)).to be_truthy }
      specify { expect(random_habitats(has_subhabitat: true).first.is_a?(Hash)).to be_truthy }
    end
  end

end