require 'rails_helper'

describe V1::CustomDevise::ConfirmationsController, :type => :controller do
  include Devise::TestHelpers

  def confirms_user(user)
    user.reload
    expect(user.confirmation_token).to be_nil
    expect(user.confirmed_at).not_to be_nil
  end

  def does_not_confirm_user(user)
    user.reload
    expect(user.confirmation_token).not_to be_nil
    expect(user.confirmed_at).to be_nil
  end

  let!(:confirmed_user) { FactoryGirl.create(:user, confirmed_at: nil, confirmation_token: nil) }

  let(:confirmation_token_1) { 'abcde' }
  let(:confirmation_token_2) { '12345' }
  let!(:unconfirmed_user) { FactoryGirl.create(:user) }

  before(:all) do
    @response_errors = {
        invalid_token: 'Confirmation token is invalid',
        blank_token: "Confirmation token can't be blank",
        already_confirmed: 'Email was already confirmed, please try signing in'
    }
  end

  before(:each) do
    request.env['devise.mapping'] = Devise.mappings[:user]

    unconfirmed_user.confirmation_token = Devise.token_generator.digest(nil, :confirmation_token, confirmation_token_1)
    unconfirmed_user.confirmed_at = nil
    unconfirmed_user.save!

    confirmed_user.confirmation_token = Devise.token_generator.digest(nil, :confirmation_token, confirmation_token_2)
    confirmed_user.confirmed_at = DateTime.now
    confirmed_user.save!

    @params_1 = { 'confirmation_token' => confirmation_token_1 }
    @params_2 = { 'confirmation_token' => confirmation_token_2 }
    @wrong_params = { 'confirmation_token' => '123' }
  end

  describe 'GET #show' do

    context 'when unconfirmed user sends the request' do
      context 'with the correct token' do
        before(:each) do
          get :show, @params_1.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_no_content }
        it { confirms_user(unconfirmed_user) }
      end

      context 'with incorrect token' do
        before(:each) do
          get :show, @wrong_params.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { does_not_confirm_user(unconfirmed_user) }
        it { is_expected.to serve_422_json_with(user_confirmation_url, [@response_errors[:invalid_token]]) }
      end

      context 'without token' do
        before(:each) do
          get :show, format: 'json'
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { does_not_confirm_user(unconfirmed_user) }
        it { is_expected.to serve_422_json_with(user_confirmation_url, [@response_errors[:blank_token]]) }
      end
    end

    context 'when confirmed user sends the request' do
      context 'with correct token' do
        before(:each) do
          get :show, @params_2.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(user_confirmation_url, [@response_errors[:already_confirmed]]) }
      end
    end

  end

end