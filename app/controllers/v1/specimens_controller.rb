class V1::SpecimensController < ApplicationController

   include Pageable
   include CamelCaseConvertible
   include Includable
   include FieldSelectable
   include FieldSearchable
   include Filterable
   include Sortable
  #
  # SPECIES_NOT_FOUND_ERROR = 'Species not found.'
  PUBLIC_FIELDS = [:date, :quantity, :note]
  PUBLIC_ASSOCIATIONS = [:species]
  #
   before_action :authenticate_user!, except: [:index, :show]
   before_action :set_inclusions, only: [:index, :show, :create, :update]
   before_action :set_fields, only: [:index, :show, :create, :update]
   # before_action { |controller| controller.send :set_pagination, Specimen, 'specimens_url' if action_name == 'index' }

  load_and_authorize_resource only: :index

  def index
    @specimens = Specimen

    @specimens = @specimens.includes(:species, :characteristics)

     search_by_fields(PUBLIC_FIELDS).each { |condition| @specimens = @specimens.where(condition) }

     association_fields = { species: V1::SpeciesController::PUBLIC_FIELDS }
     search_by_fields(association_fields).each { |condition| @specimens = @specimens.where(species: condition) }

    # association_fields = { species: V1::SpeciesController::PUBLIC_FIELDS }
    # search_by_fields(association_fields).each { |condition| @specimens = @specimens.where(species: condition) }

    if params['habitats']
      @specimens = @specimens.where('habitats like ?', '%' + params['habitats'].gsub(/,|:|-/, '%')+'%')
    end

    if params['substrates']
      @specimens = @specimens.where('substrates like ?', '%' + params['substrates'].gsub(',', '%')+'%')
    end

    set_pagination @specimens, 'specimens_url'
    @specimens = @specimens.paginate(page: @meta[:page], per_page: @meta[:per_page]) unless params['all']
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
        %w(species species.characteristics species.references)
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
        { 'species' => {
            fields: V1::SpeciesController::PUBLIC_FIELDS,
            nested_fields: {
                'characteristics' => {
                    fields: V1::CharacteristicsController::PUBLIC_FIELDS
                },
                'references' => {
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
