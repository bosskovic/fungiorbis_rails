class V1::SpeciesController < ApplicationController

  include Pageable

  PUBLIC_FIELDS = [:name, :genus, :familia, :ordo, :subclassis, :classis, :subphylum, :phylum, :synonyms]

  before_filter :authenticate_user!, :except => [:index]

  load_and_authorize_resource only: :index

  def index
    set_pagination Species, 'species_index_url'
    @species = Species.paginate(page: @meta[:page], per_page: @meta[:per_page])
  end
end
