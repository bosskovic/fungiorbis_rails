require 'rails_helper'

describe V1::CustomDevise::RegistrationsController, type: :controller do
  include Devise::TestHelpers

  def creates_user_with(user_params)
    user = User.find_by_email user_params[:email]

    expect(user).not_to be_nil
    expect(user.email).to eq(user_params[:email])
    expect(user.password).to eq(user.password_confirmation)
    expect(user.authentication_token).not_to be_nil
    expect(user.first_name).to eq(user_params[:firstName])
    expect(user.last_name).to eq(user_params[:lastName])
    expect(user.created_at).to be < Time.now
  end

  def responds_with_json_for(email)
    user = User.find_by_email email

    expect(json['href']).to include user_registration_url
    expect(json['status']).to eq 201
    expect(json).to have_key('authToken')
    expect(json['firstName']).to eq user.first_name
    expect(json['lastName']).to eq user.last_name
    expect(json['role']).to eq user.role
    expect(json['userHref']).to eq user_url(uuid: user.uuid)
  end

  def does_not_create_account
    email = @request_params[:user][:email]
    first_name = @request_params[:user][:firstName]

    expect(User.where(email: email, first_name: first_name)).to be_empty
  end


  before(:all) do
    @response_errors = {
        email_taken: 'Email has already been taken',
        email_invalid: 'Email is invalid',
        email_blank: "Email can't be blank",
        first_name_blank: "First name can't be blank",
        last_name_blank: "Last name can't be blank",
        password_blank: "Password can't be blank",
        password_mismatch: "Password confirmation doesn't match Password",
        password_too_short: 'Password is too short (minimum is 8 characters)',
        password_too_simple: 'Password must include at least one of each: lowercase letter, uppercase letter, numeric digit, special character.'
    }
  end

  before(:each) do
    request.env['devise.mapping'] = Devise.mappings[:user]

    @request_params = {
        user: {
            email: 'user@test.com',
            password: 'Password1!',
            passwordConfirmation: 'Password1!',
            firstName: 'Fungiorbis',
            lastName: 'User'
        }
    }
  end


  describe 'POST #create' do

    context 'when successfully signed up' do
      before(:each) { post :create, @request_params.merge(format: 'json') }

      subject { response }
      it { is_expected.to respond_with_created }
      it { creates_user_with @request_params[:user] }
      it { responds_with_json_for @request_params[:user][:email] }
    end

    context 'when account already exists with email equal to the one in the request' do
      before(:each) do
        existing_user = FactoryGirl.create(:user)
        @request_params[:user][:email] = existing_user.email
        post :create, @request_params.merge(format: 'json')
      end

      subject { response }
      it { is_expected.to respond_with_unprocessable }
      it { does_not_create_account }
      it { is_expected.to serve_422_json_with(user_registration_url, [@response_errors[:email_taken]]) }
    end

    context 'when the email format is invalid' do
      %w(wrong_email wrong_email@ wrong_email@a.).each do |email|
        before(:each) do
          @request_params[:user][:email] = email
          post :create, @request_params.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { does_not_create_account }
        it { is_expected.to serve_422_json_with(user_registration_url, [@response_errors[:email_invalid]]) }
      end
    end

    context 'when a mandatory field is missing' do
      context 'when email is missing' do
        before(:each) do
          @request_params[:user][:email] = nil
          post :create, @request_params.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { does_not_create_account }
        it { is_expected.to serve_422_json_with(user_registration_url, [@response_errors[:email_blank]]) }
      end

      context 'when firstName is missing' do
        before(:each) do
          @request_params[:user][:firstName] = nil
          post :create, @request_params.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { does_not_create_account }
        it { is_expected.to serve_422_json_with(user_registration_url, [@response_errors[:first_name_blank]]) }
      end

      context 'when lastName is missing' do
        before(:each) do
          @request_params[:user][:lastName] = nil
          post :create, @request_params.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { does_not_create_account }
        it { is_expected.to serve_422_json_with(user_registration_url, [@response_errors[:last_name_blank]]) }
      end

      context 'when password is missing' do
        before(:each) do
          @request_params[:user][:password] = nil
          @request_params[:user][:passwordConfirmation] = nil
          post :create, @request_params.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { does_not_create_account }
        it { is_expected.to serve_422_json_with(user_registration_url, [@response_errors[:password_blank]]) }
      end
    end

    context 'when passwordConfirmation is nil (not provided)' do
      before(:each) do
        @request_params[:user][:passwordConfirmation] = nil
        post :create, @request_params.merge(format: 'json')
      end

      subject { response }
      it { is_expected.to respond_with_created }
      it { creates_user_with @request_params[:user] }
      it { responds_with_json_for @request_params[:user][:email] }
    end


    context 'when password is invalid' do
      context 'when password and password confirmation do not mach' do
        before(:each) do
          params = @request_params.dup
          params[:user][:password] = 'Password1!'
          params[:user][:passwordConfirmation] = 'Password1!x'
          post :create, params.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { does_not_create_account }
        it { is_expected.to serve_422_json_with(user_registration_url, [@response_errors[:password_mismatch]]) }
      end

      context 'when password is too short' do
        before(:each) do
          params = @request_params.dup
          params[:user][:password] = 'Pass1!'
          params[:user][:passwordConfirmation] = 'Pass1!'
          post :create, params.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { does_not_create_account }
        it { is_expected.to serve_422_json_with(user_registration_url, [@response_errors[:password_too_short]]) }
      end

      context 'when password is too simple' do
        before(:each) do
          params = @request_params.dup
          params[:user][:password] = 'password'
          params[:user][:passwordConfirmation] = 'password'
          post :create, params.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { does_not_create_account }
        it { is_expected.to serve_422_json_with(user_registration_url, [@response_errors[:password_too_simple]]) }
      end

      context 'when password confirmation is nil and password is too simple' do
        before(:each) do
          @request_params[:user][:password] = '12345678'
          @request_params[:user][:passwordConfirmation] = nil
          post :create, @request_params.merge(format: 'json')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { does_not_create_account }
        it { is_expected.to serve_422_json_with(user_registration_url, [@response_errors[:password_too_simple]]) }
      end

    end
  end

end