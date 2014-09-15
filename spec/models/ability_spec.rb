require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability do
  subject(:ability) { Ability.new(user) }

  context 'user' do
    let(:user) { FactoryGirl.create(:user) }
    let(:another_user) { FactoryGirl.create(:user) }

    it { is_expected.to be_able_to(:show, user) }
    it { is_expected.to be_able_to(:update, user) }

    it { is_expected.not_to be_able_to(:show, another_user) }
    it { is_expected.not_to be_able_to(:update, another_user) }

    it { is_expected.not_to be_able_to(:index, User) }
    it { is_expected.not_to be_able_to(:change_role, User) }
  end

  context 'supervisor' do
    let(:user) { FactoryGirl.create(:supervisor) }

    it { is_expected.to be_able_to(:manage, User) }
    it { is_expected.to be_able_to(:change_role, User) }

    it { is_expected.to be_able_to(:manage, Species) }
  end

  context 'visitor' do
    let(:user) { nil }

    it { is_expected.to be_able_to(:index, Species) }
    it { is_expected.to be_able_to(:show, Species) }
    it { is_expected.not_to be_able_to(:create, Species) }
    it { is_expected.not_to be_able_to(:update, Species) }
  end
end