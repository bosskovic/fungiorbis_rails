# shared

CAPTURE_RECOGNIZED_STATUS = Transform /^NO CONTENT|NOT FOUND|OK|UNPROCESSABLE|FORBIDDEN|UNAUTHORIZED|CREATED$/ do |status|
  status
end

CAPTURE_RESOURCE_NAME = Transform /^user|species$/ do |resource_name|
  resource_name
end

all_fields = public_fields(:all, output: :string, include_optional: true) + %w(deactivatedAt createdAt updatedAt)
CAPTURE_FIELDS = Transform /^(?:(?:#{all_fields.join('|')})(?:,\s|\sand\s)?(?:no\s)?)+$/ do |fields|
  csv_string_to_array(fields, output: :string)
end

# users

CAPTURE_USER_TYPES = Transform /^(?:(?:confirmed user|unconfirmed user|user|contributor|supervisor|unknown user|other user|current user|deactivated user)(?:,\s|\sand\s)?)+$/ do |user_types|
  types = user_types.gsub('and', ',').split(',').map { |e| e.strip.gsub(' ', '_').to_sym }
  types.length == 1 ? types.first : types
end

user_fields = public_fields(:user, output: :string, include_optional: true) + %w(deactivatedAt createdAt updatedAt)
CAPTURE_USER_FIELDS = Transform /^(?:(?:#{user_fields.join('|')})(?:,\s|\sand\s)?(?:no\s)?)+$/ do |fields|
  csv_string_to_array(fields, output: :string)
end

# species

species_fields = public_fields(:species, output: :string)
CAPTURE_SPECIES_FIELDS = Transform /^(?:(?:#{species_fields.join('|')})(?:,\s|\sand\s)?(?:no\s)?)+$/ do |fields|
  csv_string_to_array(fields, output: :string)
end

# references

reference_fields = public_fields(:reference, output: :string)
CAPTURE_REFERENCE_FIELDS = Transform /^(?:(?:#{reference_fields.join('|')})(?:,\s|\sand\s)?(?:no\s)?)+$/ do |fields|
  csv_string_to_array(fields, output: :string)
end