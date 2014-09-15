require 'rails_helper'
require "#{Rails.root}/lib/fungiorbis/util"
require "#{Rails.root}/lib/fungiorbis/factory"

RSpec.describe V1::ReferencesController, :type => :controller do
  include Devise::TestHelpers
  include Fungiorbis::CamelCase
  include Fungiorbis::Util
  include Fungiorbis::Factory

  def public_fields
    V1::ReferencesController::PUBLIC_FIELDS
  end

  def creates_a_reference
    if @non_allowed_keys
      expect(Reference.where(to_underscore(@params)).first).to be_nil
      remove_keys_from_hash!(@params, @non_allowed_keys)
    end
    reference = Reference.where(to_underscore(@params)).first
    expect(reference).not_to be_nil
    expect(response.headers['Location']).to eq reference_url(uuid: reference.uuid)
  end

  def does_not_create_reference
    expect(Reference.where(to_underscore(@params)).first).to be_nil
  end


  def updates_a_reference(reference)
    if @non_allowed_keys
      expect(Reference.where(to_underscore(@params)).first).to be_nil
      remove_keys_from_hash!(@params, @non_allowed_keys)
    end
    expect(Reference.where(to_underscore(@params)).first.uuid).to eq reference.uuid
  end


  def does_not_update_reference(reference)
    updated_at = reference.updated_at
    reference.reload
    expect(updated_at).to eq reference.updated_at
  end

  def responds_with_reference_objects_in_array
    reference_object = json['references'].first
    reference = Reference.find_by_uuid reference_object['id']
    has_all_fields(reference_object, reference, public_fields)
  end

  describe 'GET #index' do
    context 'without any GET params' do
      before(:each) do
        FactoryGirl.create_list(:reference, 5)
        get :index, { format: 'json' }
      end

      subject { response }
      it { is_expected.to respond_with_ok }
      it { is_expected.to respond_with_objects_array(Reference) }
      it { responds_with_reference_objects_in_array }
      it { is_expected.to respond_with_links(:reference) }
    end

    it_behaves_like 'an index with meta object', Reference
  end

  describe 'GET #show' do
    context 'when requesting an existing reference resource' do
      before(:each) do
        @reference = FactoryGirl.create(:reference)
        get :show, { uuid: @reference.uuid, format: 'json' }
      end

      subject { response }
      it { is_expected.to respond_with_ok }
      it { has_all_fields(json['references'], @reference, public_fields) }
    end

    context 'when requesting non existent reference resource' do
      it_behaves_like 'not found', :get, :show, V1::ReferencesController::REFERENCE_NOT_FOUND_ERROR
    end
  end

  describe 'POST #create' do
    let(:supervisor) { FactoryGirl.create(:supervisor) }
    let(:contributor) { FactoryGirl.create(:contributor) }
    let(:user) { FactoryGirl.create(:user) }
    let(:existing_reference) { FactoryGirl.create(:reference, url: 'http://site1', isbn: 'abc1') }

    context 'with supervisor' do
      before(:each) do
        @params = to_camel_case FactoryGirl.attributes_for(:reference, url: 'http://site2', isbn: 'abc2')
        auth_token_to_headers(supervisor)
      end

      context 'when sending valid params' do
        before(:each) { post :create, { format: 'json' }.merge(references: @params) }

        subject { response }
        it { is_expected.to respond_with_created }
        specify { expect(response.body.strip).to be_empty }
        it { creates_a_reference }
      end

      context 'when sending valid params with nul url and nul isbn' do
        before(:each) do
          FactoryGirl.create(:reference, url: nil, isbn: nil)
          @params[:url] = nil
          @params[:isbn] = nil
          post :create, { format: 'json' }.merge(references: @params)
        end

        subject { response }
        it { is_expected.to respond_with_created }
        specify { expect(response.body.strip).to be_empty }
        it { creates_a_reference }
      end

      context 'when sending valid params and some unsupported params' do
        before(:each) do
          @non_allowed_keys = [:createdAt]
          @non_allowed_keys.each { |field| @params[field] = random_attribute(field) }
          post :create, { format: 'json' }.merge(references: @params)
        end

        subject { response }
        it { is_expected.to respond_with_created }
        it { has_all_fields(json['references'], Reference.find_by_uuid(json['references']['id']), public_fields) }
        it { creates_a_reference }
      end

      context 'when mandatory fields missing' do
        before(:each) do
          mandatory_keys = [:title]
          remove_keys_from_hash!(@params, mandatory_keys)
          post :create, { format: 'json' }.merge(references: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(["Title can't be blank"]) }
        it { does_not_create_reference }
      end

      context 'when url not unique' do
        before(:each) do
          @params[:url] = existing_reference.url
          post :create, { format: 'json' }.merge(references: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Url has already been taken']) }
        it { does_not_create_reference }
      end

      context 'when isbn not unique' do
        before(:each) do
          @params[:isbn] = existing_reference.isbn
          post :create, { format: 'json' }.merge(references: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Isbn has already been taken']) }
        it { does_not_create_reference }
      end
    end

    context 'with user or contributor' do
      it_behaves_like 'forbidden for non supervisors', :post, :create, { references: '' }, :reference
    end

    context 'with non authenticated user' do
      it_behaves_like 'unauthorized for non authenticated users', :post, :create, { references: '' }, :reference
    end
  end

  describe 'PATCH #update' do
    let(:supervisor) { FactoryGirl.create(:supervisor) }
    let(:contributor) { FactoryGirl.create(:contributor) }
    let(:user) { FactoryGirl.create(:user) }
    let(:other_reference) { FactoryGirl.create(:reference, url: 'http://site1', isbn: 'abc1') }
    let(:reference) { FactoryGirl.create(:reference, updated_at: DateTime.yesterday) }

    context 'with supervisor' do
      before(:each) do
        @params = to_camel_case FactoryGirl.attributes_for(:reference)
        auth_token_to_headers(supervisor)
      end

      context 'when sending valid params to existing record' do
        before(:each) { patch :update, { format: 'json', uuid: reference.uuid }.merge(references: @params) }

        subject { response }
        it { is_expected.to respond_with_no_content }
        specify { expect(response.body.strip).to be_empty }
        it { updates_a_reference(reference) }
      end

      context 'when sending valid params to existing record and some unsupported params' do
        before(:each) do
          @non_allowed_keys = [:createdAt]
          @non_allowed_keys.each { |field| @params[field] = random_attribute(field) }
          patch :update, { format: 'json', uuid: reference.uuid }.merge(references: @params)
        end

        subject { response }
        it { is_expected.to respond_with_ok }
        it { has_all_fields(json['references'], reference, public_fields) }
        it { updates_a_reference(reference) }
      end

      context 'when removing mandatory params' do
        before(:each) do
          mandatory_keys = [:title]
          mandatory_keys.each { |key| @params[key] = nil }
          patch :update, { format: 'json', uuid: reference.uuid }.merge(references: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(["Title can't be blank"]) }
        it { does_not_update_reference(reference) }
      end

      context 'when url not unique' do
        before(:each) do
          @params[:url] = other_reference.url
          patch :update, { format: 'json', uuid: reference.uuid }.merge(references: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Url has already been taken']) }
        it { does_not_update_reference(reference) }

      end

      context 'when isbn not unique' do
        before(:each) do
          @params[:isbn] = other_reference.isbn
          patch :update, { format: 'json', uuid: reference.uuid }.merge(references: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Isbn has already been taken']) }
        it { does_not_update_reference(reference) }

      end

      context 'when sending params to non existing record' do
        it_behaves_like 'not found', :patch, :update, V1::ReferencesController::REFERENCE_NOT_FOUND_ERROR
      end

    end

    context 'with user or contributor' do
      it_behaves_like 'forbidden for non supervisors', :patch, :update, { format: 'json', uuid: 'some_uuid' }, :reference
    end

    context 'with non authenticated user' do
      it_behaves_like 'unauthorized for non authenticated users', :patch, :update, { format: 'json', uuid: 'some_uuid' }, :reference
    end
  end

  describe 'DELETE #destroy' do
    let(:supervisor) { FactoryGirl.create(:supervisor) }
    let(:contributor) { FactoryGirl.create(:contributor) }
    let(:user) { FactoryGirl.create(:user) }
    let(:reference) { FactoryGirl.create(:reference) }

    context 'with supervisor' do
      before(:each) do
        auth_token_to_headers(supervisor)
      end

      context 'when deleting existing record' do
        before(:each) { delete :destroy, { format: 'json', uuid: reference.uuid } }

        subject { response }
        it { is_expected.to respond_with_no_content }
        specify { expect(response.body.strip).to be_empty }
        it { expect { reference.reload }.to raise_error(ActiveRecord::RecordNotFound) }
      end

      context 'when deleting non existing record' do
        it_behaves_like 'not found', :delete, :destroy, V1::ReferencesController::REFERENCE_NOT_FOUND_ERROR
      end
    end

    context 'with user or contributor' do
      it_behaves_like 'forbidden for non supervisors', :delete, :destroy, { format: 'json', uuid: 'some_uuid' }, :reference
    end

    context 'with non authenticated user' do
      it_behaves_like 'unauthorized for non authenticated users', :delete, :destroy, { format: 'json', uuid: 'some_uuid' }, :reference
    end
  end

end
