class CustomAuthFailure < Devise::FailureApp
  def respond
    self.status = 401
    self.headers['WWW-Authenticate'] = %(Basic realm=#{Devise.http_authentication_realm.inspect}) if http_auth_header?
    self.content_type = 'json'
    self.response_body = { status: :fail, errors: { status: '401', title: 'UNAUTHORIZED', details: [i18n_message] } }.to_json
  end
end