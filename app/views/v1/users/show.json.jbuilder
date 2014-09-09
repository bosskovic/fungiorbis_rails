json.status :success

json.links do
  json.users users_url_template
end

json.users do
  json.partial! 'v1/users/user', user: @user, include: @include
end