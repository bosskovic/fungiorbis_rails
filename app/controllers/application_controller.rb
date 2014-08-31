class ApplicationController < ActionController::Base
  check_authorization :unless => :devise_controller?

  acts_as_token_authentication_handler_for User

  respond_to :json

  # needed if the server serves anything other then json
  # protect_from_forgery with: :exception
  # protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }

  protect_from_forgery with: :null_session

  rescue_from CanCan::AccessDenied do |exception|
    render file: "#{Rails.root}/public/403.json", status: :forbidden
  end

end
