class V1::SpeciesController < ApplicationController

  include Pageable

  SPECIES_NOT_FOUND_ERROR = 'Species not found.'
  PUBLIC_FIELDS = [:name, :genus, :familia, :ordo, :subclassis, :classis, :subphylum, :phylum, :synonyms]

  before_filter :authenticate_user!, :except => [:index, :show]

  load_and_authorize_resource only: :index

  def index
    set_pagination Species, 'species_index_url'
    @species = Species.paginate(page: @meta[:page], per_page: @meta[:per_page])
  end

  def show
    authorize! :show, Species
    @species = Species.find_by_uuid(params[:uuid])
    render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [SPECIES_NOT_FOUND_ERROR] } unless @species
  end
end
