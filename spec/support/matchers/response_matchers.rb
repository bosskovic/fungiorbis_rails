RSpec::Matchers.define :respond_with_created do
  match do |response|
    expect(response.message).to eq 'Created'
    expect(response.response_code).to eq 201
  end
  failure_message do |response|
    "expected the response '201 Created', got '#{response.response_code} #{response.message} instead"
  end
  description do
    "responds with '201 Created'"
  end
end

RSpec::Matchers.define :respond_with_unprocessable do
  match do |response|
    expect(response.message).to eq 'Unprocessable Entity'
    expect(response.response_code).to eq 422
  end
  failure_message do |response|
    "expected the response '422 Unprocessable Entity', got '#{response.response_code} #{response.message} instead"
  end
  description do
    "responds with '422 Unprocessable Entity'"
  end
end

RSpec::Matchers.define :respond_with_ok do
  match do |response|
    expect(response.message).to eq 'OK'
    expect(response.response_code).to eq 200
  end
  failure_message do |response|
    "expected the response '200 OK', got '#{response.response_code} #{response.message} instead"
  end
  description do
    "responds with '200 OK'"
  end
end

RSpec::Matchers.define :respond_with_unauthorized do
  match do |response|
    expect(response.message).to eq 'Unauthorized'
    expect(response.response_code).to eq 401
  end
  failure_message do |response|
    "expected the response '200 OK', got '#{response.response_code} #{response.message} instead"
  end
  description do
    "responds with '200 OK'"
  end
end

RSpec::Matchers.define :serve_422_json_with do |href, errors|
  match do |response|
    expect(response).to render_template(file: "#{Rails.root}/public/422.json.jbuilder")
    expect(JSON.parse(response.body)['href']).to include href
    expect(JSON.parse(response.body)['errors']).to eq errors
  end


  failure_message do |response|
    "expected public/422.json, with href = '#{href}', errors = '#{errors}', got response body: '#{response.body.inspect}"
  end
  description do
    'responds with public/422.json with appropriate href and errors'
  end
end