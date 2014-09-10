# require "#{Rails.root}/app/serializers/restpack/user_serializer"

class V1::UsersController < ApplicationController
  include CamelCaseConvertible
  include Pageable

  before_filter :authenticate_user!

  load_and_authorize_resource only: :index

  USER_NOT_FOUND_ERROR = 'User not found.'
  USER_DETAILS_PARAMS = [:firstName, :lastName, :institution, :title, :phone]

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

    if only_valid_params?
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
      @allowed_param_keys = can?(:change_role, User) ? USER_DETAILS_PARAMS + [:role] : USER_DETAILS_PARAMS
      @params ||= params.fetch(:users).permit(@allowed_param_keys + [:email])
    end
    @params['deactivatedAt'] = nil if @user == current_user && !current_user.active?
    @params
  end

  def only_valid_params?
    params['users'].nil? || params.fetch(:users).keys.all? { |p| @allowed_param_keys.include?(p.to_sym) }
  end

end