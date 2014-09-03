json.href request.original_url
json.success true
json.status 201
json.authToken current_user.authentication_token
json.firstName current_user.first_name
json.lastName current_user.last_name
json.role current_user.role
json.userHref user_url(uuid: current_user.uuid)