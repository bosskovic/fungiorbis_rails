json.href request.original_url
json.success true
json.status 200
json.authToken current_user.authentication_token unless no_token
json.firstName current_user.first_name
json.lastName current_user.last_name
json.role current_user.role