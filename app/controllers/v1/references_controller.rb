class V1::ReferencesController < ApplicationController

  include Pageable
  include CamelCaseConvertible
  include Includable
  include FieldSelectable
  include Filterable
  include Sortable

  REFERENCE_NOT_FOUND_ERROR = 'Reference not found.'
  PUBLIC_FIELDS = [:title, :authors, :isbn, :url]

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_fields, only: [:index, :show, :create, :update]
  before_action :set_inclusions, only: [:index, :show, :create, :update]
  before_action { |controller| controller.send :set_pagination, Reference, 'references_url' if action_name == 'index' }

  load_and_authorize_resource

  def index
    if filter_request?
      @references = Reference.includes(:characteristics)
      filter_values.each { |value| @references = @references.where(filter_condition, { value: value }) }
      @references = @references.select(filter_response_fields)
    else
      @references = Reference.order(sort_and_order(PUBLIC_FIELDS))
      @references = @references.paginate(page: @meta[:page], per_page: @meta[:per_page])
    end
  end

  def search_by_fields
    params.each do |key, value|
      if PUBLIC_FIELDS.include?(key.to_sym)
        @references = @references.where(key.to_sym => value)
      elsif key == 'speciesId'
        @references = @references.where('species.uuid' => value)
      end
    end
  end

  def show
    @reference = Reference.includes(:characteristics).find_by_uuid(params[:uuid])
    render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [REFERENCE_NOT_FOUND_ERROR] } unless @reference
  end

  def create
    @reference = Reference.create(to_underscore(permitted_params))

    if @reference.valid? && all_passed_fields_processed?
      # head status: :created, location: reference_url(uuid: @reference.uuid)
      render json: {}, status: :created, location: reference_url(uuid: @reference.uuid)

    elsif @reference.valid?
      render :show, status: :created, location: reference_url(uuid: @reference.uuid)

    else
      render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: @reference.errors.full_messages }
    end
  end

  def update
    @reference = Reference.find_by_uuid(params[:uuid])

    unless @reference
      render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [REFERENCE_NOT_FOUND_ERROR] }
      return
    end

    @reference.update to_underscore(permitted_params)

    if @reference.valid? && all_passed_fields_processed?
      head status: :no_content
    elsif @reference.valid?
      render :show
    else
      render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: @reference.errors.full_messages }
    end
  end

  def destroy
    @reference = Reference.find_by_uuid(params[:uuid])

    unless @reference
      render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [REFERENCE_NOT_FOUND_ERROR] }
      return
    end

    if @reference.destroy
      head status: :no_content
    else
      render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: @reference.errors.full_messages }
    end
  end

  private

  def permitted_params
    @params ||= params.fetch(:references).permit(PUBLIC_FIELDS)
  end

  def all_passed_fields_processed?
    to_camel_case(params['references'].keys).all? { |f| PUBLIC_FIELDS.include? f.to_sym }
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
      when :index, :create, :update, :show
        { 'characteristics' => {
            fields: V1::CharacteristicsController::PUBLIC_FIELDS,
            nested_fields: {
                'species' => {
                    fields: [:name, :genus]
                }
            }
        } }
      else
        raise 'unsupported action'
    end
  end

  def default_inclusions(action)
    case action
      when :index
        []
      when :show, :create, :update
        %w(characteristics characteristics.species)
      else
        raise 'unsupported action'
    end
  end

  def filter_options
    { fields: PUBLIC_FIELDS, additional_fields: [:id, :fullTitle] }
  end

  def response_fields_replacements
    { 'full_title' => %w(authors title) }
  end
end