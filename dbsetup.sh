rake db:drop
rake db:create
rake db:migrate
rake environment RAILS_ENV=test db:migrate
rake db:seed