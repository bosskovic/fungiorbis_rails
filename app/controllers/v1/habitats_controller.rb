class V1::HabitatsController < ApplicationController

  def show
    authorize! :show, :habitats
    result = {}
    Array(['en']).each do |locale|
      result[locale] = habitats_yaml(locale)
    end
    render json: result
  end
end
