class V1::SpeciesController < ApplicationController

  include Pageable
  include CamelCaseConvertible

  SPECIES_NOT_FOUND_ERROR = 'Species not found.'
  PUBLIC_FIELDS = [:name, :genus, :familia, :ordo, :subclassis, :classis, :subphylum, :phylum, :synonyms, :growthType, :nutritiveGroup, :characteristics]

  before_filter :authenticate_user!, :except => [:index, :show]

  load_and_authorize_resource only: :index

  def index
    set_pagination Species, 'species_index_url'
    @species = Species.includes(:characteristics).paginate(page: @meta[:page], per_page: @meta[:per_page])
  end

  def show
    authorize! :show, Species
    @species = Species.find_by_uuid(params[:uuid])
    render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [SPECIES_NOT_FOUND_ERROR] } unless @species
  end

  def create
    authorize! :create, Species

    @species = Species.create(to_underscore(permitted_params))

    if @species.valid? && all_passed_fields_processed?
      head status: :created, location: species_url(uuid: @species.uuid)

    elsif @species.valid?
      render :show, status: :created, location: species_url(uuid: @species.uuid)

    else
      render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: @species.errors.full_messages }
    end
  end

  def update
    authorize! :update, Species

    @species = Species.find_by_uuid(params[:uuid])

    unless @species
      render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [SPECIES_NOT_FOUND_ERROR] }
      return
    end

    @species.update to_underscore(permitted_params)

    if @species.valid? && all_passed_fields_processed?
      head status: :no_content
    elsif @species.valid?
      render :show
    else
      render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: @species.errors.full_messages }
    end
  end

  def destroy
    authorize! :destroy, Species

    @species = Species.find_by_uuid(params[:uuid])

    unless @species
      render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [SPECIES_NOT_FOUND_ERROR] }
      return
    end

    if @species.destroy
      head status: :no_content
    else
      render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: @species.errors.full_messages }
    end
  end

  private

  def permitted_params
    @params ||= params.fetch(:species).permit(PUBLIC_FIELDS)
  end

  def all_passed_fields_processed?
    to_camel_case(params['species'].keys).all? { |f| PUBLIC_FIELDS.include? f.to_sym }
  end
end
