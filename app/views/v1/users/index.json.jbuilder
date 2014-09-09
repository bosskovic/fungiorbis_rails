json.status :success

json.links do
  json.users user_url_template
end

json.users @users, partial: 'v1/users/user', collection: @users, as: :user, include: nil

json.meta do
  json.users do
    json.partial! 'v1/common/meta'
  end
end