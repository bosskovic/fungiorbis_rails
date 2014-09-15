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
    end
  end
end