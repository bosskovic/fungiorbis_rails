class V1::StatsController < ApplicationController

  def show
    authorize! :show, :stats

    if params['section'] == 'species'
      stats = {
          speciesCount: Species.count,
          genusCount: Species.group(:genus).pluck(:genus).count,
          edibleCount: Species.usability_count(:edible),
          poisonousCount: Species.usability_count(:poisonous),
          medicinalCount: Species.usability_count(:medicinal),
          cultivatedCount: Species.usability_count(:cultivated)
      }

      render json: { stats: stats }
    elsif params['section'] == 'home'
      stats = {
          speciesCount: Species.count,
          specimenCount: Specimen.count,
          locationCount: Location.count,
          fieldStudiesCount: Specimen.select(:date).distinct.count,
          lastDeployAPI: (File.new('REVISION').atime rescue Time.now).strftime('%Y-%d-%m %H:%M')
      }

      render json: { stats: stats }
    else
      render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: ['not found'] }
    end


    if (Species.column_names + ['fullName']).include? params[:category]
      category = params[:category].to_sym

      render json: {
          systematics: Species.where("#{params[:category]} LIKE ?", "%#{params['value']}%").group(category).pluck(category).map { |item| { value: item } }
      }
    else

    end
  end


end
