class V1::CharacteristicController < ApplicationController
  include CamelCaseConvertible

  PUBLIC_FIELDS = [:edible, :cultivated, :poisonous, :medicinal, :fruiting_body, :microscopy, :flesh, :chemistry, :note, :habitats, :substrates]
end
