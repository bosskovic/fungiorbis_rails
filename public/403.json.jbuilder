json.status 'fail'

json.errors do
  json.status '403'
  json.title 'FORBIDDEN'
  json.details ['Insufficient privileges']
end