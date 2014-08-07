source 'https://rubygems.org'


gem 'rails', '4.1.4'
gem 'mysql2'
gem 'jbuilder', '~> 2.0'

group :development, :test do
  gem 'rspec-rails', '3.0.2'
  gem 'factory_girl_rails', '4.4.1'
  gem 'byebug'
  gem 'annotate', '~> 2.6.5'
end

group :test do
  gem 'cucumber-rails', '1.4.1', :require => false

  # subsequent versions have conflict with json_spec
  gem 'cucumber-api-steps', '0.10', :require => false
  gem 'json_spec'
  gem 'shoulda-matchers', '2.6.2'
  gem 'database_cleaner', '1.3.0'
end

group :doc do
  gem 'sdoc', '~> 0.4.0'
end

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
#gem 'spring',      group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

