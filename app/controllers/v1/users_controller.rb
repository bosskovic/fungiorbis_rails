class V1::UsersController < ApplicationController
  before_filter :authenticate_user!

  load_and_authorize_resource only: :index

  def index
    @users = User.all
    # @selected_fields = params['fields']
  end

  def show
    @user = User.find_by_uuid(params[:uuid])
    authorize! :show, @user
  end

end
