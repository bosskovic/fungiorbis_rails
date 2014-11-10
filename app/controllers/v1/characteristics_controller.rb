class V1::CharacteristicsController < ApplicationController
  include Pageable
  include CamelCaseConvertible
  include Includable
  include FieldSelectable

  PUBLIC_FIELDS = [:edible, :cultivated, :poisonous, :medicinal, :fruitingBody, :microscopy, :flesh, :chemistry, :note, :habitats, :substrates] # , :referenceId
  PUBLIC_ASSOCIATIONS = [:reference]
  CHARACTERISTIC_NOT_FOUND_ERROR = 'Species characteristic not found.'

  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_inclusions, only: [:index, :show, :create, :update]
  before_action :set_fields, only: [:index, :show, :create, :update]
  before_action { |controller| controller.send :set_pagination, Characteristic, 'species_characteristics_url' if action_name == 'index' }

  load_and_authorize_resource except: :create

  def index
    reference_id = Reference.find_by_uuid(params[:referenceId]).id if params[:referenceId]

    species = Species.find_by_uuid params[:species_uuid]
    @characteristics = Characteristic.where(species_id: species.id)
    @characteristics = @characteristics.where(reference_id: reference_id) if reference_id
    @characteristics = @characteristics.paginate(page: @meta[:page], per_page: @meta[:per_page])
  end

  def show
    @characteristic = Characteristic.includes(:species).where(uuid: params[:uuid], species: { uuid: params[:species_uuid] }).first
    render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [CHARACTERISTIC_NOT_FOUND_ERROR] } unless @characteristic
  end

  def create
    authorize! :create, Characteristic

    respond_with_body = !params['respondWithBody'].nil?

    species = Species.find_by_uuid params[:species_uuid]
    unless species
      render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: [V1::SpeciesController::SPECIES_NOT_FOUND_ERROR] }
      return
    end

    reference = params[:characteristics] && params[:characteristics][:referenceId] ? Reference.find_by_uuid(params[:characteristics][:referenceId]) : nil
    unless reference
      render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: [V1::ReferencesController::REFERENCE_NOT_FOUND_ERROR] }
      return
    end

    params = to_underscore(permitted_params).merge('species_id' => species.id, 'reference_id' => reference.id)

    @characteristic = Characteristic.create(params)

    if @characteristic.valid? && all_passed_fields_processed? && !respond_with_body
      head status: :created, location: species_characteristic_url(species_uuid: species.uuid, uuid: @characteristic.uuid)
    elsif @characteristic.valid?
      @characteristic = Characteristic.includes(:species).where(uuid: @characteristic.uuid).first
      render :show, status: :created, location: species_characteristic_url(species_uuid: species.uuid, uuid: @characteristic.uuid)

    else
      render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: @characteristic.errors.full_messages }
    end
  end

  def update
    @characteristic = Characteristic.includes(:species).where(uuid: params[:uuid], species: { uuid: params[:species_uuid] }).first

    unless @characteristic
      render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [CHARACTERISTIC_NOT_FOUND_ERROR] }
      return
    end

    if params[:characteristics] && params[:characteristics][:referenceId]
      reference = Reference.find_by_uuid(params[:characteristics][:referenceId])
      unless reference
        render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: [V1::ReferencesController::REFERENCE_NOT_FOUND_ERROR] }
        return
      end
    end
    params = to_underscore(permitted_params)
    params = params.merge('reference_id' => reference.id) if reference

    @characteristic.update to_underscore(params)

    if @characteristic.valid? && all_passed_fields_processed?
      head status: :no_content
    elsif @characteristic.valid?
      render :show
    else
      render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: @characteristic.errors.full_messages }
    end
  end

  def destroy
    @characteristic = Characteristic.includes(:species).where(uuid: params[:uuid], species: { uuid: params[:species_uuid] }).first

    unless @characteristic
      render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [CHARACTERISTIC_NOT_FOUND_ERROR] }
      return
    end

    if @characteristic.destroy
      head status: :no_content
    else
      render file: "#{Rails.root}/public/422.json", status: :unprocessable_entity, locals: { errors: @characteristic.errors.full_messages }
    end
  end

  private

  def permitted_params
    @params ||= params.require(:characteristics).permit(PUBLIC_FIELDS).tap do |white_listed|
      [:edible, :cultivated, :poisonous, :medicinal, :fruitingBody, :microscopy, :flesh, :chemistry, :note, :habitats, :substrates].each do |field|
        white_listed[field] = params[:characteristics][field] if params[:characteristics][field]
      end
    end
  end

  def all_passed_fields_processed?
    to_camel_case(params['characteristics'].keys).all? { |f| public_fields.include? f.to_sym }
  end

  def public_fields
    PUBLIC_FIELDS + [:referenceId]
  end

  def default_inclusions(action)
    case action
      when :index
        []
      when :show, :update
        %w(reference)
      when :create
        %w(reference species)
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
      when :index, :show, :update
        {
            'reference' => {
                fields: V1::ReferencesController::PUBLIC_FIELDS
            }
        }
      when :create
        {
            'reference' => {
                fields: V1::ReferencesController::PUBLIC_FIELDS
            },
            'species' => {
                fields: [:name, :genus]
            }
        }
      else
        raise 'unsupported action'
    end
  end
end
