class V1::SpeciesController < ApplicationController

  include Pageable
  include CamelCaseConvertible
  include Includable
  include FieldSelectable
  include FieldSearchable
  include Filterable
  include Sortable

  SPECIES_NOT_FOUND_ERROR = 'Species not found.'
  PUBLIC_FIELDS = [:genus, :name, :familia, :ordo, :subclassis, :classis, :subphylum, :phylum, :synonyms, :growthType, :nutritiveGroup]
  PUBLIC_ASSOCIATIONS = [:characteristics]

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_inclusions, only: [:index, :show, :create, :update]
  before_action :set_fields, only: [:index, :show, :create, :update]
  before_action { |controller| controller.send :set_pagination, Species, 'species_index_url' if action_name == 'index' }

  load_and_authorize_resource only: :index

  def index
    @species = Species

    if filter_request?
puts "---"
      filter_values.each { |value| @species = @species.where(filter_condition, { value: value }) }
      search_by_fields(PUBLIC_FIELDS).each { |condition| @species = @species.where(condition) }
      @species = @species.select(filter_response_fields)
    else
      @species = @species.includes(:characteristics).order(sort_and_order(PUBLIC_FIELDS))
      search_by_fields(PUBLIC_FIELDS).each { |condition| @species = @species.where(condition) }
      @species = @species.paginate(page: @meta[:page], per_page: @meta[:per_page]) unless params['all']
    end
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
      # head status: :created, location: species_url(uuid: @species.uuid)
      render json: {}, status: :created, location: species_url(uuid: @species.uuid)

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

  def default_inclusions(action)
    case action
      when :index
        []
      when :show, :create, :update
        %w(characteristics characteristics.reference)
      else
        raise 'unsupported action'
    end
  end

  def default_fields(action)
    case action
      when :index, :show, :create, :update
        PUBLIC_FIELDS
      else
        raise 'unsupported action'
    end
  end

  def default_nested_fields(action)
    case action
      when :index, :show, :create, :update
        { 'characteristics' => {
            fields: V1::CharacteristicsController::PUBLIC_FIELDS,
            nested_fields: {
                'reference' => {
                    fields: V1::ReferencesController::PUBLIC_FIELDS
                }
            }
        } }
      else
        raise 'unsupported action'
    end
  end

  def filter_options
    { additional_fields: [:id, :fullName], fields: PUBLIC_FIELDS }
  end

  def response_fields_replacements
    { 'full_name' => %w(name genus) }
  end
end
