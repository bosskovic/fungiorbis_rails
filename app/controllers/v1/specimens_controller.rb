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
    # @species = Species
    #
    # if filter_request?
    #   filter_values.each { |value| @species = @species.where(filter_condition, { value: value }) }
    #   search_by_fields(V1::SpeciesController::PUBLIC_FIELDS).each { |condition| @species = @species.where(condition) }
    #   @species = @species.select(filter_response_fields)
    # else
    #   @species = @species.includes(:characteristics).order(sort_and_order(V1::SpeciesController::PUBLIC_FIELDS))
    #   search_by_fields(PUBLIC_FIELDS).each { |condition| @species = @species.where(condition) }
    #
    #   association_fields = { characteristics: V1::CharacteristicsController::PUBLIC_FIELDS }
    #   search_by_fields(association_fields).each { |condition| @species = @species.where(characteristics: condition) }
    #
    #   if params['habitats']
    #     c = Characteristic.where('habitats like ?', '%' + params['habitats'].gsub(/,|:|-/, '%')+'%').pluck(:species_id)
    #     @species = @species.where(characteristics: { id: c })
    #   end
    #
    #   if params['substrates']
    #     c = Characteristic.where('substrates like ?', '%' + params['substrates'].gsub(',', '%')+'%').pluck(:species_id)
    #     @species = @species.where(characteristics: { id: c })
    #   end
    # end
    #
    # ids = @species.pluck(:id)
    #
    # @specimens = Specimen.includes(:species, :characteristics, :legator, :determinator).where(species: {id: ids})
    #
    #
    # set_pagination @specimens, 'specimens_url'
    # @specimens = @specimens.paginate(page: @meta[:page], per_page: @meta[:per_page]) unless params['all']




    @specimens = Specimen.includes(:species, :characteristics, :legator, :determinator)

    search_by_fields(PUBLIC_FIELDS).each { |condition| @specimens = @specimens.where(condition) }

    # association_fields = { species: V1::SpeciesController::PUBLIC_FIELDS }
    # search_by_fields(association_fields).each { |condition| @specimens = @specimens.where(species: condition) }

    # association_fields = { species: V1::SpeciesController::PUBLIC_FIELDS }
    # search_by_fields(association_fields).each { |condition| @specimens = @specimens.where(species: condition) }


    search_by_fields(V1::SpeciesController::PUBLIC_FIELDS).each { |condition| @specimens = @specimens.where(species: condition) }
    # params.each do |k, v|
    #   if V1::SpeciesController::PUBLIC_FIELDS.include? k.to_sym
    #     @specimens = @specimens.where(species: { k => v})
    #   end
    # end

    sp = Species.includes(:characteristics)
    params.each do |k, v|
      v = true if v == 'true'
      v = false if v == 'false'
      if ['characteristics.edible', 'characteristics.cultivated', 'characteristics.poisonous', 'characteristics.medicinal', 'characteristics.fruitingBody', 'characteristics.microscopy', 'characteristics.flesh', 'characteristics.chemistry'].include? k
        pair = k.split '.'
        # @specimens = @specimens.where(species: { characteristics:  {pair[1] => v}})
        sp = sp.where( k => v)
      end
    end
    unless sp.is_a?(Class)
      ids = sp.pluck(:id)
      puts ids.inspect
      @specimens = @specimens.where(species_id: ids)
    end


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
