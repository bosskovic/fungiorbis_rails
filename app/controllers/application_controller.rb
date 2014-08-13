class ApplicationController < ActionController::Base

  acts_as_token_authentication_handler_for User

  # needed if the server serves anything other then json
  # protect_from_forgery with: :exception
  # protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }

  protect_from_forgery with: :null_session

end
