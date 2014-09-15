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

  # def creates_a_reference
  #   if @non_allowed_keys
  #     expect(Species.where(to_underscore(@params)).first).to be_nil
  #     remove_keys_from_hash!(@params, @non_allowed_keys)
  #   end
  #   species = Species.where(to_underscore(@params)).first
  #   expect(species).not_to be_nil
  #   expect(response.headers['Location']).to eq species_url(uuid: species.uuid)
  # end

  # def updates_a_reference(species)
  #   if @non_allowed_keys
  #     expect(Species.where(to_underscore(@params)).first).to be_nil
  #     remove_keys_from_hash!(@params, @non_allowed_keys)
  #   end
  #   expect(Species.where(to_underscore(@params)).first.uuid).to eq species.uuid
  # end

  # def does_not_create_reference
  #   expect(Species.where(to_underscore(@params)).first).to be_nil
  # end

  # def does_not_update_reference(species)
  #   updated_at = species.updated_at
  #   species.reload
  #   expect(updated_at).to eq species.updated_at
  # end

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
end
