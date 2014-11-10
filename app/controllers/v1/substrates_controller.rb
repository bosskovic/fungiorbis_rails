class V1::SubstratesController < ApplicationController

  def show
    authorize! :show, :substrates
    result = {}
    Array(['en']).each do |locale|
      result[locale] = substrates_yaml(locale)
    end
    render json: result
  end
end
