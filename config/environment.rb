# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# automatically transforms ruby snake case keys to camel case, starting with lowercase
Jbuilder.key_format camelize: :lower