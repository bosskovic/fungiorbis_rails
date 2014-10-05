class V1::ReferencesController < ApplicationController

  include Pageable
  include CamelCaseConvertible
  include FieldSelectable

  REFERENCE_NOT_FOUND_ERROR = 'Reference not found.'
  PUBLIC_FIELDS = [:title, :authors, :isbn, :url]

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_fields, only: [:index, :show, :create, :update]
  before_action { |controller| controller.send :set_pagination, Reference, 'references_url' if action_name == 'index' }

  load_and_authorize_resource

  def index
    @references = Reference.paginate(page: @meta[:page], per_page: @meta[:per_page])
  end

  def show
    @reference = Reference.find_by_uuid(params[:uuid])
    render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [REFERENCE_NOT_FOUND_ERROR] } unless @reference
  end

  def create
    @reference = Reference.create(to_underscore(permitted_params))

    if @reference.valid? && all_passed_fields_processed?
      head status: :created, location: reference_url(uuid: @reference.uuid)

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
      when :index, :show, :create, :update
        { }
      else
        raise 'unsupported action'
    end
  end
end