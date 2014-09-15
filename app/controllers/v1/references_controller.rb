class V1::ReferencesController < ApplicationController

  include Pageable
  include CamelCaseConvertible

  REFERENCE_NOT_FOUND_ERROR = 'Reference not found.'
  PUBLIC_FIELDS = [:title, :authors, :isbn, :url]

  before_filter :authenticate_user!, :except => [:index, :show]

  load_and_authorize_resource

  def index
    set_pagination Reference, 'references_url'
    @references = Reference.paginate(page: @meta[:page], per_page: @meta[:per_page])
  end

  def show
  end
end
