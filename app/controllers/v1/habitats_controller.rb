require "#{Rails.root}/app/models/concerns/habitat_helper"

class V1::HabitatsController < ApplicationController

  include HabitatHelper

  def show
    authorize! :show, :habitats
    result = {}
    Array(['sr']).each do |locale|
      result[locale] = habitats_yaml(locale)
    end
    render json: result
  end
end
