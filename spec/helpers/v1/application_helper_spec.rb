require 'rails_helper'

RSpec.describe ApplicationHelper do
  include ApplicationHelper

  describe 'expand?' do
    specify { expect(expand?('resource', ['resource'])).to be_truthy }
    specify { expect(expand?(:resource, ['resource'])).to be_truthy }
    specify { expect(expand?('resource1', %w(resource1 resource2))).to be_truthy }
  end

  describe 'inclusions_for_nested_resource' do
    let(:inclusions) { %w(resource1 resource1.resource3) }
    let(:inclusions_for_resource1) { ['resource3'] }

    specify { expect(inclusions_for_nested_resource('resource1', inclusions)).to eq inclusions_for_resource1 }
  end
end
