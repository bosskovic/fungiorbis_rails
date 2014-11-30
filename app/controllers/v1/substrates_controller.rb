require "#{Rails.root}/app/models/concerns/substrate_helper"

class V1::SubstratesController < ApplicationController

  include SubstrateHelper

  def show
    authorize! :show, :substrates
    result = {}
    Array(['en']).each do |locale|
      result[locale] = substrates_yaml(locale)
    end
    render json: result
  end
end
