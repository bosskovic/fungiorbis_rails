require 'rails_helper'

describe V1::CustomDevise::SessionsController, :type => :controller do
  include Devise::TestHelpers
  include JsonSpec::Helpers

  def responds_ok_with_correct_fields
    expect(json['href']).to include user_session_url
    expect(json['success']).to be_truthy
    expect(json['status']).to eq 200
    expect(json['authToken']).not_to be_nil
    expect(json['authToken']).not_to eq old_auth_token
    expect(json['firstName']).to eq user.first_name
    expect(json['lastName']).to eq user.last_name
    expect(json['role']).to eq user.role
  end

  def responds_unauthorized_with_message(error)
    expect(json['success']).to be_falsey
    expect(json['status']).to eq 401
    expect(json['errors']).to eq [error]
  end

  def responds_unprocessable_with_message(error)
    expect(json['success']).to be_falsey
    expect(json['status']).to eq 422
    expect(json['errors']).to eq [error]
  end

  def updates_authentication_token
    token = user.authentication_token
    user.reload
    expect(token).to_not eq user.authentication_token
  end

  let(:correct_email) {'user@gmail.com'}
  let(:correct_password) {'Ab123456!'}
  let(:old_auth_token) {'auth_token'}
  let(:user) {FactoryGirl.create(:user, email: correct_email, password: correct_password, authentication_token: old_auth_token)}

  before(:all) do
    @response_errors = {
        invalid_email_or_password: I18n.t('devise.failure.invalid'),
        unconfirmed_account: I18n.t('devise.failure.unconfirmed')
    }
  end

  before(:each) do
    request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe 'POST #create' do
    context 'when successfully signed in' do
      before(:each) do
        user
        request_params = {:user => {email: correct_email, password: correct_password}}
        post :create, request_params.merge(format: 'json')
      end

      subject { response }
      it { is_expected.to respond_with_ok }
      it { responds_ok_with_correct_fields }
      it { updates_authentication_token }
    end

    context 'when user account is deactivated' do
      before(:each) do
        user.update_attributes!(deactivated_at: DateTime.now)
        request_params = {:user => {email: correct_email, password: correct_password}}
        post :create, request_params.merge(format: 'json')
      end

      subject { response }
      it { is_expected.to respond_with_unprocessable }
      it { responds_unprocessable_with_message V1::CustomDevise::SessionsController::ACCOUNT_DEACTIVATED_ERROR }
    end

    context 'when password is incorrect' do
      before(:each) do
        request_params = {:user => {email: correct_email, password: 'incorrect password'}}
        post :create, request_params.merge(format: 'json')
      end

      subject { response }
      it { is_expected.to respond_with_unauthorized }
      it { responds_unauthorized_with_message @response_errors[:invalid_email_or_password] }
    end

    context "when user's pending confirmation has timed out" do
      before(:each) do
        user.created_at = (Devise.allow_unconfirmed_access_for/60/60 + 1).days.ago
        user.confirmed_at = nil
        user.save!

        request_params = {:user => {email: correct_email, password: correct_password}}
        post :create, request_params.merge(format: 'json')
      end

      subject { response }
      it { is_expected.to respond_with_unauthorized }
      it { responds_unauthorized_with_message @response_errors[:unconfirmed_account] }
    end
  end


  describe 'DELETE #destroy' do
    context 'with correct authentication headers' do
      before(:each) do
        auth_token_to_headers(user)
        delete :destroy, { format: 'json' }
      end

      subject { response }
      it { is_expected.to respond_with_ok }
      it { updates_authentication_token }
    end

    context 'with no authentication headers' do
      before(:each) do
        delete :destroy, { format: 'json' }
      end

      subject { response }
      it { is_expected.to respond_with_unauthorized }
    end
  end

end