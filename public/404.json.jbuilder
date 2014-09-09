json.status 'fail'

json.errors do
  json.status '404'
  json.title 'NOT FOUND'
  json.details errors
end