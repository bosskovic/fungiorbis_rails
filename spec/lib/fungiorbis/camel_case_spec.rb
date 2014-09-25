require 'fungiorbis/camel_case'

RSpec.describe Fungiorbis::CamelCase do

  include Fungiorbis::CamelCase

  def hash
    { context: 'hash',
      camel_sym: { myFirstName: 'John', lastName: 'Smith' },
      snake_sym: { my_first_name: 'John', last_name: 'Smith' },
      camel_str: { 'myFirstName' => 'John', 'lastName' => 'Smith' },
      snake_str: { 'my_first_name' => 'John', 'last_name' => 'Smith' } }
  end

  def array
    { context: 'array',
      camel_sym: [:myFirstName, :lastName],
      snake_sym: [:my_first_name, :last_name],
      camel_str: %w(myFirstName lastName),
      snake_str: %w(my_first_name last_name) }
  end

  def string
    { context: 'string',
      camel_sym: :myFirstName,
      snake_sym: :my_first_name,
      camel_str: 'myFirstName',
      snake_str: 'my_first_name' }
  end


  describe '#to_underscore' do
    [:hash, :array, :string].each do |e|
      context "when argument is a #{e}" do
        before (:each) do
          @obj = send e
        end

        context 'when term is symbol' do
          it 'outputs the symbols if the option is not set otherwise' do
            expect(to_underscore(@obj[:camel_sym])).to eq @obj[:snake_sym]
          end
          it 'outputs the strings because the option is set so' do
            expect(to_underscore(@obj[:camel_sym], output: :string)).to eq @obj[:snake_str]
          end
        end

        context 'when term is string' do
          it 'outputs the strings if the option is not set otherwise' do
            expect(to_underscore(@obj[:camel_str])).to eq @obj[:snake_str]
          end
          it 'outputs the symbols because the option is set so' do
            expect(to_underscore(@obj[:camel_str], output: :symbol)).to eq @obj[:snake_sym]
          end
        end

        context 'when argument is already in snake case' do
          it 'does not affect snake case' do
            expect(to_underscore(@obj[:snake_sym])).to eq @obj[:snake_sym]
            expect(to_underscore(@obj[:snake_str])).to eq @obj[:snake_str]
          end
        end
      end
    end
  end

  describe '#to_camel_case' do
    [:hash, :array, :string].each do |e|
      context "when argument is a #{e}" do
        before (:each) do
          @obj = send e
        end

        context 'when term is symbol' do
          it 'outputs the symbols if the option is not set otherwise' do
            expect(to_camel_case(@obj[:snake_sym])).to eq @obj[:camel_sym]
          end
          it 'outputs the strings because the option is set so' do
            expect(to_camel_case(@obj[:snake_sym], output: :string)).to eq @obj[:camel_str]
          end
        end

        context 'when term is string' do
          it 'outputs the strings if the option is not set otherwise' do
            expect(to_camel_case(@obj[:snake_str])).to eq @obj[:camel_str]
          end
          it 'outputs the symbols because the option is set so' do
            expect(to_camel_case(@obj[:snake_str], output: :symbol)).to eq @obj[:camel_sym]
          end
        end

        context 'when argument is already in snake case' do
          it 'does not affect snake case' do
            expect(to_camel_case(@obj[:camel_sym])).to eq @obj[:camel_sym]
            expect(to_camel_case(@obj[:camel_str])).to eq @obj[:camel_str]
          end
        end
      end
    end
  end
end