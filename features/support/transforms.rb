# shared

CAPTURE_RECOGNIZED_STATUS = Transform /^NO CONTENT|NOT FOUND|OK|UNPROCESSABLE|FORBIDDEN|UNAUTHORIZED|CREATED$/ do |status|
  status
end

CAPTURE_RESOURCE_NAME = Transform /^user|species$/ do |resource_name|
  resource_name
end

# users

CAPTURE_USER_TYPES = Transform /^(?:(?:confirmed user|unconfirmed user|user|contributor|supervisor|unknown user|other user|current user|deactivated user)(?:,\s|\sand\s)?)+$/ do |user_types|
  types = user_types.gsub('and', ',').split(',').map { |e| e.strip.gsub(' ', '_').to_sym }
  types.length == 1 ? types.first : types
end

CAPTURE_USER_FIELDS = Transform /^(?:(?:authToken|firstName|lastName|role|email|title|institution|phone|role|deactivatedAt|createdAt|updatedAt|unconfirmedEmail)(?:,\s|\sand\s)?(?:no\s)?)+$/ do |fields|
  fields.gsub('and', ',').split(',').map { |e| e.strip }
end

# species

CAPTURE_SPECIES_FIELDS = Transform /^(?:(?:name|genus|familia|ordo|subclassis|classis|subphylum|phylum|synonyms)(?:,\s|\sand\s)?(?:no\s)?)+$/ do |fields|
  fields.gsub('and', ',').split(',').map { |e| e.strip }
end