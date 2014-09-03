class ApplicationController < ActionController::Base
  check_authorization :unless => :devise_controller?

  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  respond_to :json

  protect_from_forgery with: :null_session

  rescue_from CanCan::AccessDenied do |exception|
    render file: "#{Rails.root}/public/403.json", status: :forbidden
  end

end
