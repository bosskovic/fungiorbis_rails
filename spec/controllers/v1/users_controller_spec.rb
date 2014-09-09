require 'rails_helper'

RSpec.describe V1::UsersController, :type => :controller do
  include Devise::TestHelpers

  let(:supervisor) { FactoryGirl.create(:supervisor) }
  let(:contributor) { FactoryGirl.create(:contributor) }
  let(:user) { FactoryGirl.create(:user) }

  def has_expected_user_fields(user_object, user)
    expect(user).not_to be_nil

    expect(user_object['id']).to eq user.uuid
    expect(user_object['firstName']).to eq user.first_name
    expect(user_object['lastName']).to eq user.last_name
    expect(user_object['email']).to eq user.email
    expect(user_object['title']).to eq user.title
    expect(user_object['institution']).to eq user.institution
    expect(user_object['phone']).to eq user.phone
    expect(user_object['role']).to eq user.role

    expect(user_object.keys.length).to eq 8
  end

  describe 'GET #index' do
    context 'when authenticated as supervisor' do

      context 'without extra GET params' do
        before(:each) do
          auth_token_to_headers(supervisor)
          FactoryGirl.create_list(:user, 5)
          get :index, { format: 'json' }
        end

        subject { response }
        it { is_expected.to respond_with_ok }
        it { is_expected.to respond_with_objects_array(User) }

        it 'has the expected fields in the objects of the users array' do
          user_object = json['users'].first
          user = User.find_by_email user_object['email']
          has_expected_user_fields(user_object, user)
        end

        it { is_expected.to respond_with_meta(User, { 'page' => 1, 'perPage' => User.per_page,
                                                      'count' => User.active.count,
                                                      'include' => [],
                                                      'pageCount' => 1, 'previousPage' => nil, 'nextPage' => nil,
                                                      'previousHref' => nil, 'nextHref' => nil }) }

        it 'has the expected links object' do
          links = json['links']
          expect(links.keys.length).to eq 1
          expect(links['users']).to eq 'http://test.host/users/{users.id}'
        end
      end


      context 'with pagination' do
        before(:each) do
          auth_token_to_headers(supervisor)
          FactoryGirl.create_list(:user, 5)
        end

        context 'with perPage within limit' do
          before(:each) do
            get :index, { format: 'json', perPage: 2, page: 2 }
          end

          subject { response }
          it { is_expected.to respond_with_meta(User, { 'page' => 2, 'perPage' => 2,
                                                        'count' => User.active.count,
                                                        'include' => [],
                                                        'pageCount' => 3, 'previousPage' => 1, 'nextPage' => 3,
                                                        'previousHref' => 'http://test.host/users?page=1&perPage=2', 'nextHref' => 'http://test.host/users?page=3&perPage=2' }) }
        end

        context 'with perPage outside the limit' do
          before(:each) do
            get :index, { format: 'json', perPage: User.per_page+1 }
          end

          subject { response }
          it { is_expected.to respond_with_meta(User, { 'page' => 1, 'perPage' => User.per_page,
                                                        'count' => User.active.count,
                                                        'include' => [],
                                                        'pageCount' => 1, 'previousPage' => nil, 'nextPage' => nil,
                                                        'previousHref' => nil, 'nextHref' => nil }) }
        end

        context 'with page outside the limit' do
          before(:each) do
            get :index, { format: 'json', page: 11 }
          end

          subject { response }
          it { is_expected.to respond_with_meta(User, { 'page' => 1, 'perPage' => User.per_page,
                                                        'count' => User.active.count,
                                                        'include' => [],
                                                        'pageCount' => 1, 'previousPage' => nil, 'nextPage' => nil,
                                                        'previousHref' => nil, 'nextHref' => nil }) }
        end
      end
    end

    context 'when authenticated as plain user' do
      before(:each) do
        auth_token_to_headers(user)
        get :index, { format: 'json' }
      end

      subject { response }
      it { is_expected.to respond_with_forbidden }
    end

    context 'when authenticated as contributor' do
      before(:each) do
        auth_token_to_headers(contributor)
        get :index, { format: 'json' }
      end

      subject { response }
      it { is_expected.to respond_with_forbidden }
    end

    context 'when not authenticated' do
      before(:each) do
        get :index, { format: 'json' }
      end

      subject { response }
      it { is_expected.to respond_with_unauthorized }
    end
  end

  describe 'GET #show' do
    context 'when authenticated as supervisor' do
      before(:each) do
        auth_token_to_headers(supervisor)
      end

      context 'when requesting self' do
        before(:each) do
          get :show, { uuid: supervisor.uuid, format: 'json' }
        end

        subject { response }
        it { is_expected.to respond_with_ok }
        it { has_expected_user_fields(json['users'], supervisor) }
      end

      context 'when requesting other user' do
        before(:each) do
          get :show, { uuid: user.uuid, format: 'json' }
        end

        subject { response }
        it { is_expected.to respond_with_ok }
        it { has_expected_user_fields(json['users'], user) }
      end

      context 'when requesting non existent user' do
        before(:each) do
          get :show, { uuid: 'some_uuid', format: 'json' }
        end

        subject { response }
        it { is_expected.to respond_with_not_found([V1::UsersController::USER_NOT_FOUND_ERROR]) }
      end
    end

    context 'when authenticated as contributor' do
      before(:each) do
        auth_token_to_headers(contributor)
      end

      context 'when requesting self' do
        before(:each) do
          get :show, { uuid: contributor.uuid, format: 'json' }
        end

        subject { response }
        it { is_expected.to respond_with_ok }
        it { has_expected_user_fields(json['users'], contributor) }
      end

      context 'when requesting other user' do
        before(:each) do
          get :show, { uuid: supervisor.uuid, format: 'json' }
        end

        subject { response }
        it { is_expected.to respond_with_forbidden }
      end

      context 'when requesting non existent user' do
        before(:each) do
          get :show, { uuid: 'some_uuid', format: 'json' }
        end

        subject { response }
        it { is_expected.to respond_with_forbidden }
      end
    end

    context 'when authenticated as plain user' do
      before(:each) do
        auth_token_to_headers(user)
      end
      context 'when requesting self' do
        before(:each) do
          get :show, { uuid: user.uuid, format: 'json' }
        end

        subject { response }
        it { is_expected.to respond_with_ok }
        it { has_expected_user_fields(json['users'], user) }
      end

      context 'when requesting other user' do
        before(:each) do
          get :show, { uuid: supervisor.uuid, format: 'json' }
        end

        subject { response }
        it { is_expected.to respond_with_forbidden }
      end

      context 'when requesting non existent user' do
        before(:each) do
          get :show, { uuid: 'some_uuid', format: 'json' }
        end

        subject { response }
        it { is_expected.to respond_with_forbidden }
      end
    end

    context 'when not authenticated and requesting any user' do
      before(:each) do
        get :show, { uuid: user.uuid, format: 'json' }
      end

      subject { response }
      it { is_expected.to respond_with_unauthorized }
    end
  end
end
