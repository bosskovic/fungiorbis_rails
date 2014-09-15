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
    expect(JSON.parse(response.body)['status']).to eq 'success'
  end
  failure_message do |response|
    "expected the response '200 OK', got '#{response.response_code} #{response.message} instead"
  end
  description do
    "responds with '200 OK'"
  end
end

RSpec::Matchers.define :respond_with_no_content do
  match do |response|
    expect(response.message).to eq 'No Content'
    expect(response.response_code).to eq 204
    expect(response.body.strip).to be_empty
  end
  failure_message do |response|
    "expected the response '204 No Content', got '#{response.response_code} #{response.message} instead"
  end
  description do
    "responds with '204 NO CONTENT'"
  end
end

RSpec::Matchers.define :respond_with_not_found do |errors|
  match do |response|
    expect(response.message).to eq 'Not Found'
    expect(response.response_code).to eq 404

    body = JSON.parse(response.body)

    expect(body['status']).to eq 'fail'
    expect(body['errors']['status']).to eq '404'
    expect(body['errors']['details']).to eq errors
  end
  failure_message do |response|
    "expected the response '404 Not Found', got '#{response.response_code} #{response.message}\n
    expected ['errors']['details'] = #{errors}\n
    got: #{JSON.parse(response.body)['errors']['details']}"
  end
  description do
    "responds with '404 Not Found'"
  end
end

RSpec::Matchers.define :respond_with_unauthorized do
  match do |response|
    expect(response.message).to eq 'Unauthorized'
    expect(response.response_code).to eq 401
  end
  failure_message do |response|
    "expected the response '401 Unauthorized', got '#{response.response_code} #{response.message} instead"
  end
  description do
    "responds with '401 Unauthorized'"
  end
end

RSpec::Matchers.define :respond_with_forbidden do
  match do |response|
    expect(response.message).to eq 'Forbidden'
    expect(response.response_code).to eq 403
  end
  failure_message do |response|
    "expected the response '403 Forbidden', got '#{response.response_code} #{response.message} instead"
  end
  description do
    "responds with '403 Forbidden'"
  end
end

RSpec::Matchers.define :serve_422_json_with do |errors|
  match do |response|
    expect(response).to render_template(file: "#{Rails.root}/public/422.json.jbuilder")

    expect(JSON.parse(response.body)['status']).to eq 'fail'
    expect(JSON.parse(response.body)['errors']['status']).to eq '422'
    expect(JSON.parse(response.body)['errors']['details']).to eq errors
  end
  failure_message do |response|
    "expected the response '422 Unprocessable', got '#{response.response_code} #{response.message}\n
    expected to render_template public/422.json.jbuilder\n
    expected ['errors']['details'] = #{errors}\n
    got: #{JSON.parse(response.body)['errors']['details']}"
  end
end

RSpec::Matchers.define :respond_with_objects_array do |model|
  match do |response|
    json = JSON.parse(response.body)
    array = json[model.to_s.downcase.pluralize]
    expect(array).to be_an_instance_of(Array)

    model_count = model.count
    array_count = model_count > model.per_page ? model.per_page : model_count

    expect(array).not_to be_empty
    expect(array.count).to eq array_count
  end
end

RSpec::Matchers.define :respond_with_meta do |model_class, expected_meta|
  match do |response|
    json = JSON.parse(response.body)

    response_meta = json['meta']
    expect(response_meta.keys.length).to eq 1

    response_meta = response_meta[model_class.to_s.downcase.pluralize]
    expect(response_meta).to be_an_instance_of(Hash)

    expected_meta.each_key { |key| expect(response_meta[key]).to eq expected_meta[key] }
    expect(response_meta.keys.length).to eq expected_meta.keys.length
  end
  description do
    'responds with expected meta object'
  end
end

RSpec::Matchers.define :respond_with_links do |model|
  match do |response|
    json = JSON.parse(response.body)
    links = json['links']

    case model
      when :user, :species, :reference
        expect(links.keys.length).to eq 1
        plural = model.to_s.pluralize
        expect(links[plural]).to eq "http://test.host/#{plural}/{#{plural}.id}"
      else
        raise 'unknown model for meta links'
    end
  end
end