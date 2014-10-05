require 'fungiorbis/util'

RSpec.describe Fungiorbis::Util do

  include Fungiorbis::Util

  let(:str_hash) { { 'firstName' => 'John', 'lastName' => 'Smith', 'title' => 'Mr.' } }
  let(:sym_hash) { { firstName: 'John', lastName: 'Smith', title: 'Mr.' } }

  describe 'remove_keys_from_hash!' do
    context 'when keys are symbols' do
      it 'removes the specified key' do
        remove_keys_from_hash!(sym_hash, [:lastName])
        expect(sym_hash).to eq(firstName: 'John', title: 'Mr.')
      end
    end

    context 'when keys are strings' do
      it 'removes the specified key' do
        remove_keys_from_hash!(str_hash, ['lastName'])
        expect(str_hash).to eq('firstName' => 'John', 'title' => 'Mr.')
      end
    end

    context 'when requesting removal of non existent key' do
      it 'makes no changes' do
        original_hash = sym_hash.dup
        remove_keys_from_hash!(sym_hash, [:phone])
        expect(sym_hash).to eq(original_hash)
      end
    end

    context 'when requesting removal from empty hash' do
      it 'makes no changes' do
        empty_hash = {}
        remove_keys_from_hash!(empty_hash, [:phone])
        expect(empty_hash).to be_empty
      end
    end
  end

  describe 'keep_keys_in_hash!' do
    context 'when keys are symbols' do
      it 'removes the keys that are not specified' do
        keep_keys_in_hash!(sym_hash, [:firstName, :title])
        expect(sym_hash).to eq(firstName: 'John', title: 'Mr.')
      end
    end

    context 'when keys are strings' do
      it 'removes the keys that are not specified' do
        keep_keys_in_hash!(str_hash, %w(firstName title))
        expect(str_hash).to eq('firstName' => 'John', 'title' => 'Mr.')
      end
    end

    context 'when requesting to keep non existent elements' do
      it 'returns empty hash' do
        keep_keys_in_hash!(str_hash, %w(phone))
        expect(str_hash).to be_empty
      end
    end

    context 'when requesting to keep elements in empty hash' do
      it 'returns empty hash' do
        str_hash = {}
        keep_keys_in_hash!(str_hash, %w(phone))
        expect(str_hash).to be_empty
      end
    end
  end

  describe 'csv_string_to_array' do
    shared_examples_for 'csv_string_to_array' do
      it 'returns expected array of strings' do
        expect(csv_string_to_array(csv_string)).to eq array_str
      end

      it 'returns expected array of symbols' do
        expect(csv_string_to_array(csv_string, output: :symbol)).to eq array_sym
      end
    end

    context 'with only commas as separators' do
      let(:csv_string) { 'first_name,last_name, phone  ,   institution' }
      let(:array_str) { %w(first_name last_name phone institution) }
      let(:array_sym) { [:first_name, :last_name, :phone, :institution] }

      it_behaves_like 'csv_string_to_array'
    end

    context 'with "and" as separator' do
      let(:csv_string) { 'first_name,last_name and phone, candle , land and institution' }
      let(:array_str) { %w(first_name last_name phone candle land institution) }
      let(:array_sym) { [:first_name, :last_name, :phone, :candle, :land, :institution] }

      it_behaves_like 'csv_string_to_array'
    end

    context 'with blank string' do
      let(:csv_string) { '' }
      let(:array_str) { [] }
      let(:array_sym) { [] }

      it_behaves_like 'csv_string_to_array'
    end

    context 'with nil string' do
      let(:csv_string) { nil }
      let(:array_str) { [] }
      let(:array_sym) { [] }

      it_behaves_like 'csv_string_to_array'
    end

    context 'with a single value in string' do
      let(:csv_string) { 'name' }
      let(:array_str) { ['name'] }
      let(:array_sym) { [:name] }

      it_behaves_like 'csv_string_to_array'
    end

    context 'with empty values within csv string' do
      let(:csv_string) { 'name, , and phone' }
      let(:array_str) { %w(name phone) }
      let(:array_sym) { [:name, :phone] }

      it_behaves_like 'csv_string_to_array'
    end
  end

  describe 'hash_access' do
    let(:hash) { {
        h1: {
            h11: {
                h111: 123
            },
            'h12' => {
                'h121' => 111
            },
            h13: 999
        },
        h2: {
            h21: 888
        },
        h3: 123
    } }

    context 'when root key requested' do
      specify { expect(hash_access(hash, 'h3')).to eq 123 }
      specify { expect(hash_access(hash, 'h2')).to eq ({ :h21 => 888 }) }
    end

    context 'when middle key requested' do
      specify { expect(hash_access(hash, 'h1.h11')).to eq hash[:h1][:h11] }
      specify { expect(hash_access(hash, 'h1.h12')).to eq hash[:h1]['h12'] }
    end

    context 'when leaf key requested' do
      specify { expect(hash_access(hash, 'h1.h11.h111')).to eq hash[:h1][:h11][:h111] }
      specify { expect(hash_access(hash, 'h1.h12.h121')).to eq hash[:h1]['h12']['h121'] }
    end

    context 'when invalid arguments' do
      context 'with empty hash' do
        specify { expect(hash_access({}, 'h3')).to be_nil }
      end

      context 'with empty path' do
        it 'returns the complete hash' do
          expect(hash_access(hash, '')).to eq hash
        end
      end

      context 'with incorrect path' do
        specify { expect(hash_access(hash, 'some_key')).to be_nil }
      end
    end
  end

end