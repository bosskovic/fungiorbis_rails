require 'rails_helper'
require "#{Rails.root}/app/models/concerns/substrate_helper"

RSpec.describe SubstrateHelper do

  include SubstrateHelper

  describe '#all_substrate_keys' do
    specify { expect(all_substrate_keys.is_a?(Array)).to be_truthy }
  end

  describe '#random_substrates' do
    context 'without arguments' do
      specify { expect(random_substrates.is_a?(Array)).to be_truthy }
    end

    context 'with correct arguments' do
      specify { expect(random_substrates(number_of_substrates: 1).is_a?(Array)).to be_truthy }
      specify { expect(random_substrates(number_of_substrates: 1).length).to eq 1 }
    end

    context 'with incorrect arguments' do
      context 'when number of substrates is 0' do
        specify { expect { random_substrates(number_of_substrates: 0) }.to raise_error(StandardError) }
      end

      context 'when number of substrates is not integer' do
        specify { expect { random_substrates(number_of_substrates: a) }.to raise_error(StandardError) }
      end

      context 'when number of substrates is larger then number of available substrates' do
        specify { expect { random_substrates(number_of_substrates: 1000) }.to raise_error(StandardError) }
      end
    end
  end
end