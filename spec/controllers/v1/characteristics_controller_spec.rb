require 'rails_helper'

RSpec.describe V1::CharacteristicsController, :type => :controller do
  include Devise::TestHelpers
  include Fungiorbis::CamelCase

  def public_fields
    V1::CharacteristicsController::PUBLIC_FIELDS
  end

  def public_reference_fields
    V1::ReferencesController::PUBLIC_FIELDS
  end

  def creates_a_characteristic
    params = @params.dup
    params.delete(:referenceId)
    params = to_underscore(params)
    [:fruiting_body, :microscopy, :flesh, :chemistry, :note, :substrates, :habitats].each do |key|
      params[key] = params[key].to_json
    end

    if @non_allowed_keys
      expect(Characteristic.where(params).first).to be_nil
      remove_keys_from_hash!(params, to_underscore(@non_allowed_keys))
    end

    characteristic = Characteristic.where(params).first
    expect(characteristic).not_to be_nil
    expect(response.headers['Location']).to eq species_characteristic_url(uuid: characteristic.uuid, species_uuid: characteristic.species.uuid)
  end

  def does_not_create_characteristic
    expect(Characteristic.where(to_underscore(@params)).first).to be_nil
  end

  def updates_a_characteristic(characteristic)
    params = @params.dup
    params.delete(:referenceId)
    params = to_underscore(params)
    [:fruiting_body, :microscopy, :flesh, :chemistry, :note, :substrates, :habitats].each do |key|
      params[key] = params[key].to_json
    end

    if @non_allowed_keys
      expect(Characteristic.where(params).first).to be_nil
      remove_keys_from_hash!(params, to_underscore(@non_allowed_keys))
    end

    expect(Characteristic.where(params).first.uuid).to eq characteristic.uuid
  end


  def does_not_update_characteristic(characteristic)
    updated_at = characteristic.updated_at
    characteristic.reload
    expect(updated_at).to eq characteristic.updated_at
  end

  def responds_with_characteristic_objects_in_array(fields=public_fields)
    characteristic_object = json['characteristics'].first
    characteristic = Characteristic.find_by_uuid characteristic_object['id']
    has_all_fields(characteristic_object, characteristic, fields)
  end

  def includes_reference_object(fields=public_reference_fields)
    reference_object = json['characteristics'].first['reference']
    reference = Reference.find_by_uuid reference_object['id']
    has_all_fields(reference_object, reference, fields)
  end

  describe 'GET #index' do
    context 'without any GET params' do
      before(:each) do
        FactoryGirl.create(:species_with_characteristics)
        get :index, { format: 'json', species_uuid: Species.first.uuid }
      end

      subject { response }
      it { is_expected.to respond_with_ok }
      it { is_expected.to respond_with_objects_array(Characteristic) }
      it { responds_with_characteristic_objects_in_array }
      it { has_all_links(json, 'characteristics', ['reference', 'species']) }
      it { is_expected.to respond_with_links(:characteristic) }
    end

    context 'with specified reference id' do
      before(:each) do
        @reference = FactoryGirl.create(:reference_with_characteristics)
        get :index, { format: 'json', species_uuid: Species.first.uuid, referenceId: @reference.uuid }
      end

      context do
        subject { response }
        it { is_expected.to respond_with_ok }
        it { is_expected.to respond_with_objects_array(Characteristic) }
        it { responds_with_characteristic_objects_in_array }
        it { has_all_links(json, 'characteristics', ['reference', 'species']) }
        it { is_expected.to respond_with_links(:characteristic) }
      end

      it 'belongs to the specified reference id' do
        json['characteristics'].each do |c|
          expect(c['links']['reference']).to eq @reference.uuid
        end
      end
    end

    context 'with custom fields' do
      let(:fields) { [:edible, :cultivated] }

      before(:each) do
        FactoryGirl.create(:species_with_characteristics)
        get :index, { format: 'json', species_uuid: Species.first.uuid, 'fields' => fields.join(',') }
      end

      subject { response }
      it { is_expected.to respond_with_ok }
      it { is_expected.to respond_with_objects_array(Characteristic) }
      it { responds_with_characteristic_objects_in_array(fields) }
      it { is_expected.to respond_with_links(:characteristic) }
    end

    context 'with custom inclusion' do
      let(:inclusion) { :reference }
      let(:fields) { [:title, :isbn] }

      before(:each) do
        FactoryGirl.create(:species_with_characteristics)
        get :index, { format: 'json', species_uuid: Species.first.uuid, 'include' => inclusion.to_s, "fields[#{inclusion}]" => fields.join(',') }
      end

      subject { response }
      it { is_expected.to respond_with_ok }
      it { is_expected.to respond_with_objects_array(Characteristic) }
      it { responds_with_characteristic_objects_in_array }
      it { includes_reference_object(fields) }
      it { is_expected.to respond_with_links(:characteristic) }
    end

    it_behaves_like 'an index with meta object', Characteristic
  end

  describe 'GET #show' do
    context 'when requesting an existing characteristic resource' do
      before(:each) do
        @characteristic = FactoryGirl.create(:characteristic)
        get :show, { uuid: @characteristic.uuid, species_uuid: @characteristic.species.uuid, format: 'json' }
      end

      subject { response }
      it { is_expected.to respond_with_ok }
      it { has_all_fields(json['characteristics'], @characteristic, public_fields) }
    end

    context 'when requesting non existent characteristic resource' do
      it_behaves_like 'not found', :get, :show, V1::CharacteristicsController::CHARACTERISTIC_NOT_FOUND_ERROR, { species_uuid: 'some_species_uuid' }
    end
  end

  describe 'POST #create' do
    let(:supervisor) { FactoryGirl.create(:supervisor) }
    let(:contributor) { FactoryGirl.create(:contributor) }
    let(:user) { FactoryGirl.create(:user) }
    let!(:existing_characteristic) { FactoryGirl.create(:characteristic, edible: true, cultivated: true) }

    context 'with supervisor' do
      before(:each) do
        @params = to_camel_case FactoryGirl.attributes_for(:characteristic, edible: false, cultivated: false, referenceId: existing_characteristic.reference.uuid)
        auth_token_to_headers(supervisor)
      end

      context 'when sending valid params' do
        before(:each) { post :create, { format: 'json' }.merge(characteristics: @params, species_uuid: Species.first.uuid) }

        subject { response }
        it { is_expected.to respond_with_created }
        specify { expect(response.body.strip).to be_empty }
        it { creates_a_characteristic }
      end

      context 'when sending valid params and requesting response body' do
        before(:each) { post :create, { format: 'json', respondWithBody: 'true' }.merge(characteristics: @params, species_uuid: Species.first.uuid) }

        subject { response }
        it { is_expected.to respond_with_created }
        it { has_all_fields(json['characteristics'], Characteristic.last, public_fields) }
        it 'includes name and genus of the species in the response' do
          expect(json['characteristics']['species']['name']).not_to be_nil
          expect(json['characteristics']['species']['genus']).not_to be_nil
        end
        it { creates_a_characteristic }
      end

      context 'when sending valid params and some unsupported params' do
        before(:each) do
          @non_allowed_keys = [:createdAt]
          @non_allowed_keys.each { |field| @params[field] = random_attribute(field) }
          post :create, { format: 'json' }.merge(characteristics: @params, species_uuid: Species.first.uuid)
        end

        subject { response }
        it { is_expected.to respond_with_created }
        it { has_all_fields(json['characteristics'], Characteristic.find_by_uuid(json['characteristics']['id']), public_fields) }
        it { creates_a_characteristic }
      end

      context 'when mandatory fields missing' do
        before(:each) do
          mandatory_keys = [:referenceId]
          remove_keys_from_hash!(@params, mandatory_keys)
          post :create, { format: 'json' }.merge(characteristics: @params, species_uuid: Species.first.uuid)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Reference not found.']) }
        it { does_not_create_characteristic }
      end

      context 'when incorrect species_uuid in request url' do
        before(:each) do
          post :create, { format: 'json' }.merge(characteristics: @params, species_uuid: 'some_uuid')
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Species not found.']) }
        it { does_not_create_characteristic }
      end

      context 'when incorrect habitats' do
        before(:each) do
          @params[:habitats] = [{ ocean: {} }]
          post :create, { format: 'json' }.merge(characteristics: @params, species_uuid: Species.first.uuid)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Habitats have to be included in: ["forest", "meadow", "sands", "peat", "anthropogenic"]']) }
        it { does_not_create_characteristic }
      end

      context 'when incorrect subhabitat' do
        before(:each) do
          key = @params[:habitats].first.keys.first
          @params[:habitats].first[key][:subhabitat] = :ocean
          post :create, { format: 'json' }.merge(characteristics: @params, species_uuid: Species.first.uuid)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Habitats must take subhabitats from the list for specific habitat']) }
        it { does_not_create_characteristic }
      end

      context 'when incorrect species' do
        before(:each) do
          key = @params[:habitats].first.keys.first
          @params[:habitats].first[key][:species] = :dog
          post :create, { format: 'json' }.merge(characteristics: @params, species_uuid: Species.first.uuid)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Habitats must take species from the list for specific habitat and subhabitat']) }
        it { does_not_create_characteristic }
      end
    end

    context 'with user or contributor' do
      it_behaves_like 'forbidden for non supervisors', :post, :create, { characteristics: '', species_uuid: 'some_uuid' }, :characteristic
    end

    context 'with non authenticated user' do
      it_behaves_like 'unauthorized for non authenticated users', :post, :create, { characteristics: '', species_uuid: 'some_uuid' }, :characteristic
    end
  end

  describe 'PATCH #update' do
    let(:supervisor) { FactoryGirl.create(:supervisor) }
    let(:contributor) { FactoryGirl.create(:contributor) }
    let(:user) { FactoryGirl.create(:user) }
    let(:other_characteristic) { FactoryGirl.create(:characteristic, edible: true, cultivated: true) }
    let(:characteristic) { FactoryGirl.create(:characteristic, updated_at: DateTime.yesterday) }

    context 'with supervisor' do
      before(:each) do
        @params = to_camel_case FactoryGirl.attributes_for(:characteristic)
        auth_token_to_headers(supervisor)
      end

      context 'when sending valid params to existing record' do
        before(:each) { patch :update, { format: 'json', uuid: characteristic.uuid, species_uuid: characteristic.species.uuid }.merge(characteristics: @params) }

        subject { response }
        it { is_expected.to respond_with_no_content }
        specify { expect(response.body.strip).to be_empty }
        it { updates_a_characteristic(characteristic) }
      end

      context 'when sending valid params and requesting response body' do
        before(:each) { patch :update, { format: 'json', respondWithBody: 'true', uuid: characteristic.uuid, species_uuid: characteristic.species.uuid }.merge(characteristics: @params) }

        subject { response }
        it { is_expected.to respond_with_ok }
        it { has_all_fields(json['characteristics'], characteristic, public_fields) }
        it 'includes name and genus of the species in the response' do
          expect(json['characteristics']['species']['name']).not_to be_nil
          expect(json['characteristics']['species']['genus']).not_to be_nil
        end
        it { updates_a_characteristic(characteristic) }
      end

      context 'when sending valid params to existing record and some unsupported params' do
        before(:each) do
          @non_allowed_keys = [:createdAt]
          @non_allowed_keys.each { |field| @params[field] = random_attribute(field) }
          patch :update, { format: 'json', uuid: characteristic.uuid, species_uuid: characteristic.species.uuid }.merge(characteristics: @params)
        end

        subject { response }
        it { is_expected.to respond_with_ok }
        it { has_all_fields(json['characteristics'], characteristic, public_fields) }
        it { updates_a_characteristic(characteristic) }
      end

      context 'when removing mandatory params' do
        before(:each) do
          mandatory_keys = [:referenceId]
          mandatory_keys.each { |key| @params[key] = 'null' }
          patch :update, { format: 'json', uuid: characteristic.uuid, species_uuid: characteristic.species.uuid }.merge(characteristics: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Reference not found.']) }
        it { does_not_update_characteristic(characteristic) }
      end

      context 'when sending params to non existing record' do
        it_behaves_like 'not found', :patch, :update, V1::CharacteristicsController::CHARACTERISTIC_NOT_FOUND_ERROR, { species_uuid: 'some_uuid' }
      end

      context 'when incorrect species_uuid in request url' do
        before(:each) do
          patch :update, { format: 'json', uuid: characteristic.uuid, species_uuid: 'some_uuid' }.merge(characteristics: @params)
        end

        subject { response }
        it { is_expected.to respond_with_not_found(['Species characteristic not found.']) }
        it { does_not_update_characteristic(characteristic) }
      end

      context 'when incorrect habitats' do
        before(:each) do
          @params[:habitats] = [{ ocean: {} }]
          patch :update, { format: 'json', uuid: characteristic.uuid, species_uuid: characteristic.species.uuid }.merge(characteristics: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Habitats have to be included in: ["forest", "meadow", "sands", "peat", "anthropogenic"]']) }
        it { does_not_update_characteristic(characteristic) }
      end

      context 'when incorrect subhabitat' do
        before(:each) do
          key = @params[:habitats].first.keys.first
          @params[:habitats].first[key][:subhabitat] = :ocean
          patch :update, { format: 'json', uuid: characteristic.uuid, species_uuid: characteristic.species.uuid }.merge(characteristics: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Habitats must take subhabitats from the list for specific habitat']) }
        it { does_not_update_characteristic(characteristic) }
      end

      context 'when incorrect species' do
        before(:each) do
          key = @params[:habitats].first.keys.first
          @params[:habitats].first[key][:species] = :dog
          patch :update, { format: 'json', uuid: characteristic.uuid, species_uuid: characteristic.species.uuid }.merge(characteristics: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Habitats must take species from the list for specific habitat and subhabitat']) }
        it { does_not_update_characteristic(characteristic) }
      end
    end

    context 'with user or contributor' do
      it_behaves_like 'forbidden for non supervisors', :patch, :update, { format: 'json', uuid: 'some_uuid', species_uuid: 'some_uuid' }, :characteristic
    end

    context 'with non authenticated user' do
      it_behaves_like 'unauthorized for non authenticated users', :patch, :update, { format: 'json', uuid: 'some_uuid', species_uuid: 'some_uuid' }, :characteristic
    end
  end

  describe 'DELETE #destroy' do
    let(:supervisor) { FactoryGirl.create(:supervisor) }
    let(:contributor) { FactoryGirl.create(:contributor) }
    let(:user) { FactoryGirl.create(:user) }
    let(:characteristic) { FactoryGirl.create(:characteristic) }

    context 'with supervisor' do
      before(:each) do
        auth_token_to_headers(supervisor)
      end

      context 'when deleting existing record' do
        before(:each) { delete :destroy, { format: 'json', uuid: characteristic.uuid, species_uuid: characteristic.species.uuid } }

        subject { response }
        it { is_expected.to respond_with_no_content }
        specify { expect(response.body.strip).to be_empty }
        it { expect { characteristic.reload }.to raise_error(ActiveRecord::RecordNotFound) }
      end

      context 'when deleting non existing record' do
        it_behaves_like 'not found', :delete, :destroy, V1::CharacteristicsController::CHARACTERISTIC_NOT_FOUND_ERROR, { species_uuid: 'some_uuid' }
      end
    end

    context 'with user or contributor' do
      it_behaves_like 'forbidden for non supervisors', :delete, :destroy, { format: 'json', uuid: 'some_uuid', species_uuid: 'some_uuid' }, :characteristic
    end

    context 'with non authenticated user' do
      it_behaves_like 'unauthorized for non authenticated users', :delete, :destroy, { format: 'json', uuid: 'some_uuid', species_uuid: 'some_uuid' }, :characteristic
    end
  end
end
