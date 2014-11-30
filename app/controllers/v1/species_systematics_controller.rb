class V1::SpeciesSystematicsController < ApplicationController

  def show
    authorize! :show, :species_systematics
    if (Species.column_names + ['fullName']).include? params[:category]
      category = params[:category].to_sym

      render json: {
          systematics: Species.where("#{params[:category]} LIKE ?", "%#{params['value']}%").group(category).pluck(category).map { |item| { value: item }}
      }
    else
      render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: ['not found'] }
    end
  end

end
