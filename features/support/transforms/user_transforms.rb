CAPTURE_USER_TYPES = Transform /^(?:(?:confirmed user|unconfirmed user|user|contributor|supervisor|unknown user|other user|current user|deactivated user)(?:,\s|\sand\s)?)+$/ do |user_types|
  types = user_types.gsub('and', ',').split(',').map { |e| e.strip.gsub(' ', '_').to_sym }
  types.length == 1 ? types.first : types
end

CAPTURE_USER_FIELDS = Transform /^(?:(?:authToken|firstName|lastName|role|email|title|institution|phone|role|deactivatedAt|createdAt|updatedAt|unconfirmedEmail)(?:,\s|\sand\s)?(?:no\s)?)+$/ do |fields|
  fields.gsub('and', ',').split(',').map { |e| e.strip }
end