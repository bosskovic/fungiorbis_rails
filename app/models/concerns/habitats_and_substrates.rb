require "#{Rails.root}/lib/fungiorbis/habitat_helper"
require "#{Rails.root}/lib/fungiorbis/substrate_helper"

module HabitatsAndSubstrates
  extend ActiveSupport::Concern

  include Fungiorbis::HabitatHelper
  include Fungiorbis::SubstrateHelper
end