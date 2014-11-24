bundle exec rake environment RAILS_ENV=production db:drop
bundle exec rake environment RAILS_ENV=production db:create
bundle exec rake environment RAILS_ENV=production db:migrate
#rake environment RAILS_ENV=test db:migrate
bundle exec rake environment RAILS_ENV=production db:seed