RSpec.shared_examples 'an index with meta object' do |model_class|
  before(:each) do
    FactoryGirl.create_list(model_class.to_s.downcase.to_sym, (model_class.per_page * 2.5).to_i)
  end
  describe 'pagination' do
    [{ context: 'without meta params', perPage: nil, page: nil },
     { context: 'with perPage within limit', perPage: model_class.per_page-1, page: 2 },
     { context: 'with perPage outside the limit', perPage: model_class.per_page+1, page: 3 },
     { context: 'with page outside the limit', perPage: nil, page: 11 }].each do |pagination_context|

      context pagination_context[:context] do
        before(:each) do
          additional_params = model_class == Characteristic ? { species_uuid: Species.first.uuid } : {}
          get :index, { format: 'json', perPage: pagination_context[:perPage], page: pagination_context[:page] }.merge(additional_params)
        end

        subject { response }
        it { is_expected.to respond_with_meta(model_class, send(:pagination_with_context, pagination_context[:context], model_class)) }
      end
    end
  end
end