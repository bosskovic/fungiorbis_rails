json.id user.uuid
json.href user_url(:uuid => user.uuid)

user_fields = [:first_name, :last_name, :email, :title, :institution, :phone, :role, :deactivated_at, :created_at, :updated_at]

# TODO custom fields (including nested fields) in request
# json.extract! user, *selective_fields(user_fields, @selected_fields[:not_nested])

json.extract! user, *user_fields

# TODO optional offset and pagination in request