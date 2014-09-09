json.status 'error'

json.errors do
  json.status '500'
  json.title 'Internal Server Error'
  json.details errors
end