class ApplicationController < ActionController::Base
  check_authorization :unless => :devise_controller?

  acts_as_token_authentication_handler_for User, fallback_to_devise: false

  respond_to :json

  skip_before_filter  :verify_authenticity_token

  if Rails.env.production?
    rescue_from StandardError do |e|
      render file: "#{Rails.root}/public/500.json", status: :internal_server_error, locals: {errors: [e.message]}
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    render file: "#{Rails.root}/public/403.json", status: :forbidden
  end

end
