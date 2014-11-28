require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  subject(:ability) { Ability.new(user) }

  context 'when user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:another_user) { FactoryGirl.create(:user) }

    it { is_expected.to be_able_to(:show, user) }
    it { is_expected.to be_able_to(:update, user) }

    it { is_expected.not_to be_able_to(:show, another_user) }
    it { is_expected.not_to be_able_to(:update, another_user) }

    it { is_expected.not_to be_able_to(:index, User) }
    it { is_expected.not_to be_able_to(:change_role, User) }
  end

  context 'when supervisor' do
    let(:user) { FactoryGirl.create(:supervisor) }

    it { is_expected.to be_able_to(:manage, User) }
    it { is_expected.to be_able_to(:change_role, User) }

    it { is_expected.to be_able_to(:manage, Species) }
    it { is_expected.to be_able_to(:manage, Reference) }
    it { is_expected.to be_able_to(:manage, Characteristic) }
    it { is_expected.to be_able_to(:manage, Location) }
    it { is_expected.to be_able_to(:manage, Specimen) }
  end

  context 'when visitor' do
    let(:user) { nil }

    context 'with Species' do
      it { is_expected.to be_able_to(:index, Species) }
      it { is_expected.to be_able_to(:show, Species) }
      it { is_expected.not_to be_able_to(:create, Species) }
      it { is_expected.not_to be_able_to(:update, Species) }
      it { is_expected.not_to be_able_to(:destroy, Species) }
    end

    context 'with Reference' do
      it { is_expected.to be_able_to(:index, Reference) }
      it { is_expected.to be_able_to(:show, Reference) }
      it { is_expected.not_to be_able_to(:create, Reference) }
      it { is_expected.not_to be_able_to(:update, Reference) }
      it { is_expected.not_to be_able_to(:destroy, Reference) }
    end

    context 'with Characteristic' do
      it { is_expected.to be_able_to(:index, Characteristic) }
      it { is_expected.to be_able_to(:show, Characteristic) }
      it { is_expected.not_to be_able_to(:create, Characteristic) }
      it { is_expected.not_to be_able_to(:update, Characteristic) }
      it { is_expected.not_to be_able_to(:destroy, Characteristic) }
    end

    context 'with Location' do
      it { is_expected.to be_able_to(:index, Location) }
      it { is_expected.to be_able_to(:show, Location) }
      it { is_expected.not_to be_able_to(:create, Location) }
      it { is_expected.not_to be_able_to(:update, Location) }
      it { is_expected.not_to be_able_to(:destroy, Location) }
    end

    context 'with Specimen' do
      it { is_expected.to be_able_to(:index, Specimen) }
      it { is_expected.to be_able_to(:show, Specimen) }
      it { is_expected.not_to be_able_to(:create, Specimen) }
      it { is_expected.not_to be_able_to(:update, Specimen) }
      it { is_expected.not_to be_able_to(:destroy, Specimen) }
    end

    context 'with Habitats' do
      it { is_expected.to be_able_to(:show, :habitats) }
    end

    context 'with Substrates' do
      it { is_expected.to be_able_to(:show, :substrates) }
    end
  end
end