require 'rails_helper'

RSpec.describe V1::UsersController, :type => :controller do
  include Devise::TestHelpers

  let(:supervisor) { FactoryGirl.create(:supervisor) }
  let(:contributor) { FactoryGirl.create(:contributor) }
  let(:user) { FactoryGirl.create(:user) }


  def public_fields
    V1::UsersController::PUBLIC_FIELDS
  end

  def optional_response_fields
    V1::UsersController::OPTIONAL_RESPONSE_FIELDS
  end

  def responds_with_user_objects_in_array
    user_object = json['users'].first
    user = User.find_by_email user_object['email']
    has_all_fields(user_object, user, public_fields, optional_response_fields)
  end


  describe 'GET #index' do

    context 'when authenticated' do

      context 'as supervisor' do

        before(:each) { auth_token_to_headers(supervisor) }

        it_behaves_like 'an index with meta object', User

        context 'without any GET params' do
          before(:each) do
            FactoryGirl.create_list(:user, 5)
            get :index, { format: 'json' }
          end

          subject { response }
          it { is_expected.to respond_with_ok }
          it { is_expected.to respond_with_objects_array(User) }
          it { responds_with_user_objects_in_array }
          it { is_expected.to respond_with_links(:user) }
        end
      end

      context 'when signed in user is not supervisor' do
        it_behaves_like 'forbidden for non supervisors', :get, :index, {}, :user
      end
    end

    context 'when not authenticated' do
      it_behaves_like 'unauthorized for non authenticated users', :get, :index, {}, :user
    end
  end


  describe 'GET #show' do
    context 'when authenticated' do

      [:user, :contributor, :supervisor].each do |user_role|

        context "as #{user_role}" do
          before(:each) { auth_token_to_headers(@any_user = FactoryGirl.create(user_role)) }

          context 'when requesting self' do
            before(:each) { get :show, { uuid: @any_user.uuid, format: 'json' } }

            subject { response }
            it { is_expected.to respond_with_ok }
            it { has_all_fields(json['users'], @any_user, public_fields, optional_response_fields) }
          end
        end
      end

      context 'as supervisor' do
        before(:each) { auth_token_to_headers(supervisor) }

        context 'when requesting other user' do
          before(:each) { get :show, { uuid: user.uuid, format: 'json' } }

          subject { response }
          it { is_expected.to respond_with_ok }
          it { has_all_fields(json['users'], user, public_fields, optional_response_fields) }
        end

        context 'when requesting non existent user' do
          before(:each) { get :show, { uuid: 'some_uuid', format: 'json' } }

          subject { response }
          it { is_expected.to respond_with_not_found([V1::UsersController::USER_NOT_FOUND_ERROR]) }
        end
      end

      context 'when signed in user is not supervisor' do
        it_behaves_like 'forbidden for non supervisors', :get, :show, {}, :user
        it_behaves_like 'forbidden for non supervisors', :get, :show, { uuid: 'some_uuid' }, :user
      end

    end

    context 'when not authenticated and requesting any user' do
      it_behaves_like 'unauthorized for non authenticated users', :get, :show, {}, :user
    end
  end


  describe 'PUT #update' do
    context 'when authenticated' do

      [:user, :contributor, :supervisor].each do |user_role|

        context "as #{user_role}" do

          before(:each) { auth_token_to_headers(@any_user = FactoryGirl.create(user_role)) }

          context 'when updating self' do

            context 'with only public fields excluding email and role' do
              before(:each) do
                @params = random_attributes_hash_for(public_fields - [:email, :role], User)
                patch :update, { uuid: @any_user.uuid, format: 'json' }.merge(@params)
              end

              subject { response }
              it { is_expected.to respond_with_no_content }
              it { has_updated_attributes(@params[:users], @any_user) }
            end

            context 'with some non-permitted fields (updatedAt) excluding email' do
              before(:each) do
                patch :update, { uuid: @any_user.uuid, format: 'json' }.merge(random_attributes_hash_for([:firstName, :updatedAt], User, @any_user))
              end

              subject { response }
              it { is_expected.to respond_with_ok }
              it { has_all_fields(json['users'], @any_user, public_fields, optional_response_fields) }
            end

            context 'with email' do
              before(:each) do
                @params = random_attributes_hash_for([:firstName, :email], User)
                patch :update, { uuid: @any_user.uuid, format: 'json' }.merge(@params)
              end

              subject { response }
              it { is_expected.to respond_with_ok }
              it { has_all_fields(json['users'], @any_user, public_fields, optional_response_fields) }
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

          context 'with only public fields including role, excluding email' do
            before(:each) do
              patch :update, { uuid: user.uuid, format: 'json' }.merge(random_attributes_hash_for(public_fields - [:email], User))
            end

            subject { response }
            it { is_expected.to respond_with_no_content }
          end

          context 'with some non-permitted fields (updatedAt) excluding email' do
            before(:each) do
              patch :update, { uuid: user.uuid, format: 'json' }.merge(random_attributes_hash_for([:firstName, :updatedAt], User, user))
            end

            subject { response }
            it { is_expected.to respond_with_ok }
            it { has_all_fields(json['users'], user, public_fields, optional_response_fields) }
          end

          context 'with role' do
            before(:each) do
              patch :update, { uuid: user.uuid, format: 'json' }.merge(random_attributes_hash_for([:firstName, :role], User, user))
            end

            subject { response }
            it { is_expected.to respond_with_no_content }
          end

          context 'with email' do
            before(:each) do
              patch :update, { uuid: user.uuid, format: 'json' }.merge(random_attributes_hash_for([:firstName, :email], User))
            end

            subject { response }
            it { is_expected.to respond_with_ok }
            it { has_all_fields(json['users'], user, public_fields, optional_response_fields) }
          end
        end

        context 'when requesting non existent user' do
          before(:each) do
            patch :update, { uuid: 'some_uuid', format: 'json' }.merge(random_attributes_hash_for([:firstName], User))
          end

          subject { response }
          it { is_expected.to respond_with_not_found([V1::UsersController::USER_NOT_FOUND_ERROR]) }
        end
      end

      context 'when signed in user is not supervisor and trying to update other user' do
        it_behaves_like 'forbidden for non supervisors', :patch, :update, {}, :user
        it_behaves_like 'forbidden for non supervisors', :patch, :update, { uuid: 'some_uuid' }, :user
      end
    end

    context 'when not signed in and updating any user' do
      it_behaves_like 'unauthorized for non authenticated users', :patch, :update, {}, :user
    end

    context 'when authenticated as deactivated user' do
      before(:each) { auth_token_to_headers(@user = FactoryGirl.create(:deactivated_user)) }

      context 'with no params' do
        before(:each) do
          patch :update, { uuid: @user.uuid, format: 'json' }
          @user.reload
        end

        specify { expect(@user.active?).to be_truthy }
      end

      context 'with params' do
        before(:each) do
          @params = random_attributes_hash_for([:firstName], User)
          patch :update, { uuid: @user.uuid, format: 'json' }.merge(@params)
          @user.reload
        end

        specify { expect(@user.active?).to be_truthy }
        specify { expect(@user.first_name).to eq @params[:users][:firstName] }
      end
    end
  end
end
