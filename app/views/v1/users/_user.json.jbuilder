json.id user.uuid

user_fields = [:first_name, :last_name, :email, :title, :institution, :phone, :role]
json.extract! user, *user_fields

json.authToken user.authentication_token if include && include[:authToken]