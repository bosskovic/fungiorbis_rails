require 'rails_helper'

RSpec.describe V1::SubstratesController, :type => :controller do
  include Devise::TestHelpers

  describe 'GET show' do
    it 'returns http success' do
      get :show
      expect(response).to be_success
    end
  end

end
