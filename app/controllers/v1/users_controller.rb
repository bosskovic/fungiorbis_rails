class V1::UsersController < ApplicationController
  include CamelCaseConvertible
  include Pageable

  before_filter :authenticate_user!

  load_and_authorize_resource only: :index

  USER_NOT_FOUND_ERROR = 'User not found.'
  PUBLIC_FIELDS = [:email, :firstName, :lastName, :institution, :title, :phone, :role]
  OPTIONAL_RESPONSE_FIELDS = [:unconfirmedEmail]

  def index
    set_pagination User, 'users_url'
    @users = User.active.paginate(page: @meta[:page], per_page: @meta[:per_page])

    head :no_content if @users.empty?
  end

  def show
    @user = User.find_by_uuid(params[:uuid])
    authorize! :show, @user
    render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [USER_NOT_FOUND_ERROR] } unless @user
  end

  def update
    @user = User.find_by_uuid(params[:uuid])
    authorize! :update, @user

    unless @user
      render file: "#{Rails.root}/public/404.json", status: :not_found, locals: { errors: [USER_NOT_FOUND_ERROR] }
      return
    end

    @user.update_attributes! keys_to_underscore(update_params)

    if params['users'].nil? || all_passed_fields_processed?
      head :no_content
    else
      render :show
    end
  end

  private

  def update_params
    if params['users'].nil?
      @params = {}
    else
      @params ||= params.fetch(:users).permit(public_fields)
    end
    @params['deactivatedAt'] = nil if @user == current_user && !current_user.active?
    @params
  end

  def all_passed_fields_processed?
    email_change_requested = params['users']['email'] && params['users']['email'] != current_user.email
    unprocessed_fields = params['users'].dup.reject { |f| public_fields.include? f.to_sym }
    unprocessed_fields.empty? && !email_change_requested
  end

  def public_fields
    can?(:change_role, User) ? PUBLIC_FIELDS : PUBLIC_FIELDS - [:role]
  end
end