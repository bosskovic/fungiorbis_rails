require 'rails_helper'
require "#{Rails.root}/lib/fungiorbis/util"
require "#{Rails.root}/lib/fungiorbis/factory"

RSpec.describe V1::SpeciesController, :type => :controller do
  include Devise::TestHelpers
  include Fungiorbis::CamelCase
  include Fungiorbis::Util
  include Fungiorbis::Factory

  def public_fields
    V1::SpeciesController::PUBLIC_FIELDS
  end

  def creates_a_species
    if @non_allowed_keys
      expect(Species.where(to_underscore(@params)).first).to be_nil
      remove_keys_from_hash!(@params, @non_allowed_keys)
    end
    species = Species.where(to_underscore(@params)).first
    expect(species).not_to be_nil
    expect(response.headers['Location']).to eq species_url(uuid: species.uuid)
  end

  def updates_a_species(species)
    if @non_allowed_keys
      expect(Species.where(to_underscore(@params)).first).to be_nil
      remove_keys_from_hash!(@params, @non_allowed_keys)
    end
    expect(Species.where(to_underscore(@params)).first.uuid).to eq species.uuid
  end

  def does_not_create_species
    expect(Species.where(to_underscore(@params)).first).to be_nil
  end

  def does_not_update_species(species)
    updated_at = species.updated_at
    species.reload
    expect(updated_at).to eq species.updated_at
  end

  def responds_with_species_objects_in_array
    species_object = json['species'].first
    species = Species.find_by_uuid species_object['id']
    has_all_fields(species_object, species, public_fields)
  end

  describe 'GET #index' do
    context 'without any GET params' do
      before(:each) do
        FactoryGirl.create_list(:species, 5)
        get :index, { format: 'json' }
      end

      subject { response }
      it { is_expected.to respond_with_ok }
      it { is_expected.to respond_with_objects_array(Species) }
      it { responds_with_species_objects_in_array }
      it { is_expected.to respond_with_links(:species) }
    end

    it_behaves_like 'an index with meta object', Species
  end

  describe 'GET #show' do

    context 'when requesting an existing species resource' do
      before(:each) do
        @species = FactoryGirl.create(:species)
        get :show, { uuid: @species.uuid, format: 'json' }
      end

      subject { response }
      it { is_expected.to respond_with_ok }
      it { has_all_fields(json['species'], @species, public_fields) }
    end

    context 'when requesting non existent species resource' do
      it_behaves_like 'not found', :get, :show, V1::SpeciesController::SPECIES_NOT_FOUND_ERROR
    end
  end

  describe 'POST #create' do
    let(:supervisor) { FactoryGirl.create(:supervisor) }
    let(:contributor) { FactoryGirl.create(:contributor) }
    let(:user) { FactoryGirl.create(:user) }
    let(:existing_species) { FactoryGirl.create(:species) }

    context 'with supervisor' do
      before(:each) do
        @params = to_camel_case FactoryGirl.attributes_for(:species)
        auth_token_to_headers(supervisor)
      end

      context 'when sending valid params' do
        before(:each) { post :create, { format: 'json' }.merge(species: @params) }

        subject { response }
        it { is_expected.to respond_with_created }
        specify { expect(response.body.strip).to be_empty }
        it { creates_a_species }
      end

      context 'when sending valid params and some unsupported params' do
        before(:each) do
          @non_allowed_keys = [:createdAt]
          @non_allowed_keys.each { |field| @params[field] = random_attribute(field) }
          post :create, { format: 'json' }.merge(species: @params)
        end

        subject { response }
        it { is_expected.to respond_with_created }
        it { has_all_fields(json['species'], Species.find_by_uuid(json['species']['id']), public_fields) }
        it { creates_a_species }
      end

      context 'when mandatory fields missing' do
        before(:each) do
          mandatory_keys = [:name, :genus, :familia, :ordo, :subclassis, :classis, :subphylum, :phylum]
          remove_keys_from_hash!(@params, mandatory_keys)
          post :create, { format: 'json' }.merge(species: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(["Name can't be blank", "Genus can't be blank", "Familia can't be blank", "Ordo can't be blank", "Subclassis can't be blank", "Classis can't be blank", "Subphylum can't be blank", "Phylum can't be blank"]) }
        it { does_not_create_species }
      end

      context 'when name-genus not unique' do
        before(:each) do
          @params[:name] = existing_species.name
          @params[:genus] = existing_species.genus
          post :create, { format: 'json' }.merge(species: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Name - genus combination must be unique']) }
        it { does_not_create_species }
      end

      context 'when invalid growth type' do
        before(:each) do
          @params[:growthType] = 'abc'
          post :create, { format: 'json' }.merge(species: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(["Growth type has to be one of: [\"single\", \"group\"]"]) }
        it { does_not_create_species }
      end

      context 'when invalid nutritive group' do
        before(:each) do
          @params[:nutritiveGroup] = 'abc'
          post :create, { format: 'json' }.merge(species: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(["Nutritive group has to be one of: [\"parasitic\", \"mycorrhizal\", \"saprotrophic\", \"parasitic-saprotrophic\", \"saprotrophic-parasitic\"]"]) }
        it { does_not_create_species }
      end

    end

    context 'with user or contributor' do
      it_behaves_like 'forbidden for non supervisors', :post, :create, { species: '' }, :species
    end

    context 'with non authenticated user' do
      it_behaves_like 'unauthorized for non authenticated users', :post, :create, { species: '' }, :species
    end
  end


  describe 'PATCH #update' do
    let(:supervisor) { FactoryGirl.create(:supervisor) }
    let(:contributor) { FactoryGirl.create(:contributor) }
    let(:user) { FactoryGirl.create(:user) }
    let(:other_species) { FactoryGirl.create(:species) }
    let(:species) { FactoryGirl.create(:species, updated_at: DateTime.yesterday) }

    context 'with supervisor' do
      before(:each) do
        @params = to_camel_case FactoryGirl.attributes_for(:species)
        auth_token_to_headers(supervisor)
      end

      context 'when sending valid params to existing record' do
        before(:each) { patch :update, { format: 'json', uuid: species.uuid }.merge(species: @params) }

        subject { response }
        it { is_expected.to respond_with_no_content }
        specify { expect(response.body.strip).to be_empty }
        it { updates_a_species(species) }
      end

      context 'when sending valid params to existing record and some unsupported params' do
        before(:each) do
          @non_allowed_keys = [:createdAt]
          @non_allowed_keys.each { |field| @params[field] = random_attribute(field) }
          patch :update, { format: 'json', uuid: species.uuid }.merge(species: @params)
        end

        subject { response }
        it { is_expected.to respond_with_ok }
        it { has_all_fields(json['species'], species, public_fields) }
        it { updates_a_species(species) }
      end

      context 'when removing mandatory params' do
        before(:each) do
          mandatory_keys = [:name, :genus, :familia, :ordo, :subclassis, :classis, :subphylum, :phylum]
          mandatory_keys.each { |key| @params[key] = nil }
          patch :update, { format: 'json', uuid: species.uuid }.merge(species: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(["Name can't be blank", "Genus can't be blank", "Familia can't be blank", "Ordo can't be blank", "Subclassis can't be blank", "Classis can't be blank", "Subphylum can't be blank", "Phylum can't be blank"]) }
        it { does_not_update_species(species) }
      end

      context 'when name-genus not unique' do
        before(:each) do
          @params[:name] = other_species.name
          @params[:genus] = other_species.genus
          patch :update, { format: 'json', uuid: species.uuid }.merge(species: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(['Name - genus combination must be unique']) }
        it { does_not_update_species(species) }

      end

      context 'when invalid growth type' do
        before(:each) do
          @params[:growthType] = 'abc'
          patch :update, { format: 'json', uuid: species.uuid }.merge(species: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(["Growth type has to be one of: [\"single\", \"group\"]"]) }
        it { does_not_update_species(species) }

      end

      context 'when invalid nutritive group' do
        before(:each) do
          @params[:nutritiveGroup] = 'abc'
          patch :update, { format: 'json', uuid: species.uuid }.merge(species: @params)
        end

        subject { response }
        it { is_expected.to respond_with_unprocessable }
        it { is_expected.to serve_422_json_with(["Nutritive group has to be one of: [\"parasitic\", \"mycorrhizal\", \"saprotrophic\", \"parasitic-saprotrophic\", \"saprotrophic-parasitic\"]"]) }
        it { does_not_update_species(species) }
      end

      context 'when sending params to non existing record' do
        it_behaves_like 'not found', :patch, :update, V1::SpeciesController::SPECIES_NOT_FOUND_ERROR
      end

    end

    context 'with user or contributor' do
      it_behaves_like 'forbidden for non supervisors', :patch, :update, { format: 'json', species: { uuid: 'some_uuid' } }, :species
    end

    context 'with non authenticated user' do
      it_behaves_like 'unauthorized for non authenticated users', :patch, :update, { format: 'json', species: { uuid: 'some_uuid' } }, :species
    end

  end

end
