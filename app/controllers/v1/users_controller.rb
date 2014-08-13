class V1::UsersController < ApplicationController

  respond_to :json

  def index
    users =  User.all
    render json: users, status: :ok
  end

end
