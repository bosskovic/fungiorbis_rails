# require "#{Rails.root}/app/serializers/restpack/user_serializer"

class V1::UsersController < ApplicationController
  include CamelCaseConvertible
  include Pageable

  before_filter :authenticate_user!

  load_and_authorize_resource only: :index

  USER_NOT_FOUND_ERROR = 'User not found.'

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


end
