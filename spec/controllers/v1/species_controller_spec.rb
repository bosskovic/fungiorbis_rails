require 'rails_helper'

RSpec.describe V1::SpeciesController, :type => :controller do
  include Devise::TestHelpers

  def public_fields
    V1::SpeciesController::PUBLIC_FIELDS
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

end
