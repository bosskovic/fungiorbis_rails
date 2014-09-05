json.href request.original_url
json.success true
json.status 200
json.users @users, partial: 'v1/users/user', collection: @users, as: :user
json.count @users.count
