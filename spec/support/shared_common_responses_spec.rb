RSpec.shared_examples 'forbidden for non supervisors' do |method, action, params, model|
  [:user, :contributor].each do |user_by_role|
    before(:each) do
      auth_token_to_headers(FactoryGirl.create(user_by_role))
      if [:show, :update].include? action
        send(method, action, { format: 'json', uuid: FactoryGirl.create(model).uuid }.merge(params))
      else
        send(method, action, { format: 'json' }.merge(params))
      end
    end

    subject { response }
    it { is_expected.to respond_with_forbidden }
  end
end

RSpec.shared_examples 'unauthorized for non authenticated users' do |method, action, params, model|
  before(:each) do
    if [:show, :update].include? action
      send(method, action, { format: 'json', uuid: FactoryGirl.create(model).uuid }.merge(params))
    else
      send(method, action, { format: 'json' }.merge(params))
    end
  end

  subject { response }
  it { is_expected.to respond_with_unauthorized }
end