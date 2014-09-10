require 'rails_helper'

RSpec.describe V1::UsersController, :type => :controller do
  include Devise::TestHelpers

  let(:supervisor) { FactoryGirl.create(:supervisor) }
  let(:contributor) { FactoryGirl.create(:contributor) }
  let(:user) { FactoryGirl.create(:user) }

  def has_expected_user_fields(user_object, user)
    expect(user).not_to be_nil
    user.reload

    expect(user_object['id']).to eq user.uuid
    expect(user_object['firstName']).to eq user.first_name
    expect(user_object['lastName']).to eq user.last_name
    expect(user_object['email']).to eq user.email
    expect(user_object['title']).to eq user.title
    expect(user_object['institution']).to eq user.institution
    expect(user_object['phone']).to eq user.phone
    expect(user_object['role']).to eq user.role

    if user_object['unconfirmedEmail']
      expect(user_object['unconfirmedEmail']).to eq user.unconfirmed_email
      expect(user_object.keys.length).to eq 9
    else
      expect(user_object.keys.length).to eq 8
    end
  end


  def random_attributes_hash_for(fields, selected_user=nil)
    params = {}
    fields.each { |field| params[field] = random_user_attribute field, selected_user }

    { users: params }
  end

  def random_user_attribute(field, user=nil)
    case field
      when :firstName
        Faker::Name.first_name
      when :lastName
        Faker::Name.last_name
      when :title
        Faker::Name.prefix
      when :institution
        Faker::Company.name
      when :phone
        Faker::PhoneNumber.phone_number
      when :email
        Faker::Internet.email
      when :role
        user && user.role == 'user' ? 'supervisor' : 'user'
      when :updatedAt
        DateTime.now
      else
        raise 'unknown user field'
    end
  end

  def first_of_one_pages
    { 'page' => 1,
      'perPage' => User.per_page,
      'count' => User.active.count,
      'include' => [],
      'pageCount' => 1,
      'previousPage' => nil, 'nextPage' => nil,
      'previousHref' => nil, 'nextHref' => nil }
  end

  def second_of_three_pages
    { 'page' => 2,
      'perPage' => 2,
      'count' => User.active.count,
      'include' => [],
      'pageCount' => 3,
      'previousPage' => 1, 'nextPage' => 3,
      'previousHref' => 'http://test.host/users?page=1&perPage=2', 'nextHref' => 'http://test.host/users?page=3&perPage=2' }
  end

  def has_updated_attributes(user, attributes)
    user.reload

    attributes.each_key do |key|
      snake_key = key.to_s.underscore.to_sym
      expect(user[snake_key]).to eq attributes[key]
    end
  end

  describe 'GET #index' do

    context 'when authenticated' do

      context 'as supervisor' do

        before(:each) do
          auth_token_to_headers(supervisor)
          FactoryGirl.create_list(:user, 5)
        end

        context 'without any GET params' do

          before(:each) { get :index, { format: 'json' } }

          subject { response }
          it { is_expected.to respond_with_ok }
          it { is_expected.to respond_with_objects_array(User) }

          it 'has the expected fields in the objects of the users array' do
            user_object = json['users'].first
            user = User.find_by_email user_object['email']
            has_expected_user_fields(user_object, user)
          end

          it { is_expected.to respond_with_meta(User, first_of_one_pages) }

          it 'has the expected links object' do
            links = json['links']
            expect(links.keys.length).to eq 1
            expect(links['users']).to eq 'http://test.host/users/{users.id}'
          end
        end


        context 'with pagination' do
          [{ context: 'with perPage within limit', perPage: 2, page: 2, response: :second_of_three_pages },
           { context: 'with perPage outside the limit', perPage: User.per_page+1, page: nil, response: :first_of_one_pages },
           { context: 'with page outside the limit', perPage: nil, page: 11, response: :first_of_one_pages }].each do |pagination_context|

            context pagination_context[:context] do
              before(:each) { get :index, { format: 'json', perPage: pagination_context[:perPage], page: pagination_context[:page] } }

              subject { response }
              it { is_expected.to respond_with_meta(User, send(pagination_context[:response])) }
            end
          end
        end
      end

      [:user, :contributor].each do |user_role|
        context "as #{user_role}" do
          before(:each) do
            @user_or_contributor = FactoryGirl.create(user_role)
            auth_token_to_headers(@user_or_contributor)
            get :index, { format: 'json' }
          end

          subject { response }
          it { is_expected.to respond_with_forbidden }
        end
      end
    end


    context 'when not authenticated' do
      before(:each) { get :index, { format: 'json' } }

      subject { response }
      it { is_expected.to respond_with_unauthorized }
    end
  end


  describe 'GET #show' do
    context 'when authenticated' do

      [:user, :contributor, :supervisor].each do |user_role|

        context "as #{user_role}" do

          before(:each) do
            @any_user = FactoryGirl.create(user_role)
            auth_token_to_headers(@any_user)
          end

          context 'when requesting self' do
            before(:each) do
              get :show, { uuid: @any_user.uuid, format: 'json' }
            end

            subject { response }
            it { is_expected.to respond_with_ok }
            it { has_expected_user_fields(json['users'], @any_user) }
          end
        end
      end

      context 'as supervisor' do
        before(:each) { auth_token_to_headers(supervisor) }

        context 'when requesting other user' do
          before(:each) { get :show, { uuid: user.uuid, format: 'json' } }

          subject { response }
          it { is_expected.to respond_with_ok }
          it { has_expected_user_fields(json['users'], user) }
        end

        context 'when requesting non existent user' do
          before(:each) { get :show, { uuid: 'some_uuid', format: 'json' } }

          subject { response }
          it { is_expected.to respond_with_not_found([V1::UsersController::USER_NOT_FOUND_ERROR]) }
        end
      end

      [:user, :contributor].each do |user_role|

        context "when authenticated as #{user_role}" do

          before(:each) do
            @user_or_contributor = FactoryGirl.create(user_role)
            auth_token_to_headers(@user_or_contributor)
          end

          context 'when requesting other user' do
            before(:each) { get :show, { uuid: supervisor.uuid, format: 'json' } }

            subject { response }
            it { is_expected.to respond_with_forbidden }
          end

          context 'when requesting non existent user' do
            before(:each) { get :show, { uuid: 'some_uuid', format: 'json' } }

            subject { response }
            it { is_expected.to respond_with_forbidden }
          end
        end
      end

    end

    context 'when not authenticated and requesting any user' do
      before(:each) { get :show, { uuid: user.uuid, format: 'json' } }

      subject { response }
      it { is_expected.to respond_with_unauthorized }
    end
  end


  describe 'PUT #update' do
    context 'when authenticated' do

      [:user, :contributor, :supervisor].each do |user_role|

        context "as #{user_role}" do

          before(:each) do
            @any_user = FactoryGirl.create(user_role)
            auth_token_to_headers(@any_user)
          end

          context 'when updating self' do

            context 'with only permitted fields excluding email' do
              before(:each) do
                @params = random_attributes_hash_for(V1::UsersController::USER_DETAILS_PARAMS)
                patch :update, { uuid: @any_user.uuid, format: 'json' }.merge(@params)
              end

              subject { response }
              it { is_expected.to respond_with_no_content }
              it { has_updated_attributes(@any_user, @params[:users]) }
            end

            context 'with some non-permitted fields (updatedAt) excluding email' do
              before(:each) do
                patch :update, { uuid: @any_user.uuid, format: 'json' }.merge(random_attributes_hash_for([:firstName, :updatedAt], @any_user))
              end

              subject { response }
              it { is_expected.to respond_with_ok }
              it { has_expected_user_fields(json['users'], @any_user) }
            end

            context 'with email' do
              before(:each) do
                @params = random_attributes_hash_for([:firstName, :email])
                patch :update, { uuid: @any_user.uuid, format: 'json' }.merge(@params)
              end

              subject { response }
              it { is_expected.to respond_with_ok }
              it { has_expected_user_fields(json['users'], @any_user) }
              it 'sets unconfirmed_email and does not change email' do
                @any_user.reload
                expect(@any_user.unconfirmed_email).to eq @params[:users][:email]
                expect(@any_user.email).not_to eq @params[:users][:email]
              end

            end
          end
        end
      end

      context 'as supervisor' do
        before(:each) { auth_token_to_headers(supervisor) }

        context 'when updating other user' do

          context 'with only permitted fields excluding email' do
            before(:each) do
              patch :update, { uuid: user.uuid, format: 'json' }.merge(random_attributes_hash_for(V1::UsersController::USER_DETAILS_PARAMS))
            end

            subject { response }
            it { is_expected.to respond_with_no_content }
          end

          context 'with some non-permitted fields (updatedAt) excluding email' do
            before(:each) do
              patch :update, { uuid: user.uuid, format: 'json' }.merge(random_attributes_hash_for([:firstName, :updatedAt], user))
            end

            subject { response }
            it { is_expected.to respond_with_ok }
            it { has_expected_user_fields(json['users'], user) }
          end

          context 'with role' do
            before(:each) do
              patch :update, { uuid: user.uuid, format: 'json' }.merge(random_attributes_hash_for([:firstName, :role], user))
            end

            subject { response }
            it { is_expected.to respond_with_no_content }
          end

          context 'with email' do
            before(:each) do
              patch :update, { uuid: user.uuid, format: 'json' }.merge(random_attributes_hash_for([:firstName, :email]))
            end

            subject { response }
            it { is_expected.to respond_with_ok }
            it { has_expected_user_fields(json['users'], user) }
          end
        end

        context 'when requesting non existent user' do
          before(:each) do
            patch :update, { uuid: 'some_uuid', format: 'json' }.merge(random_attributes_hash_for([:firstName]))
          end

          subject { response }
          it { is_expected.to respond_with_not_found([V1::UsersController::USER_NOT_FOUND_ERROR]) }
        end
      end

      [:user, :contributor].each do |user_role|
        context "when authenticated as #{user_role}" do
          before(:each) do
            @user_or_contributor = FactoryGirl.create(user_role)
            auth_token_to_headers(@user_or_contributor)
          end

          context 'when updating other user' do
            before(:each) do
              patch :update, { uuid: supervisor.uuid, format: 'json' }.merge(random_attributes_hash_for([:firstName]))
            end

            subject { response }
            it { is_expected.to respond_with_forbidden }
          end

          context 'when updating non existent user' do
            before(:each) do
              patch :update, { uuid: 'some_uuid', format: 'json' }.merge(random_attributes_hash_for([:firstName]))
            end

            subject { response }
            it { is_expected.to respond_with_forbidden }
          end
        end
      end
    end

    context 'when not authenticated and updating any user' do
      before(:each) do
        patch :update, { uuid: user.uuid, format: 'json' }.merge(random_attributes_hash_for([:firstName]))
      end

      subject { response }
      it { is_expected.to respond_with_unauthorized }
    end

    context 'when authenticated as deactivated user' do
      before(:each) do
        @user = FactoryGirl.create(:user)
        @user.deactivate!
        auth_token_to_headers(@user)
      end

      context 'with no params' do
        before(:each) do
          patch :update, { uuid: @user.uuid, format: 'json' }
          @user.reload
        end

        specify { expect(@user.active?).to be_truthy }
      end

      context 'with params' do
        before(:each) do
          @params = random_attributes_hash_for([:firstName])
          patch :update, { uuid: @user.uuid, format: 'json' }.merge(@params)
          @user.reload
        end

        specify { expect(@user.active?).to be_truthy }
        specify { expect(@user.first_name).to eq @params[:users][:firstName] }
      end
    end
  end
end
