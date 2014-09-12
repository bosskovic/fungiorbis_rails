json.id user.uuid

user_fields = V1::UsersController::PUBLIC_FIELDS.map { |f| f.to_s.underscore.to_sym }
json.extract! user, *user_fields

json.authToken user.authentication_token if include && include[:authToken]
json.unconfirmedEmail user.unconfirmed_email if user.unconfirmed_email