json.status 'fail'

json.errors do
  json.status '422'
  json.title 'UNPROCESSABLE'
  json.details errors
end