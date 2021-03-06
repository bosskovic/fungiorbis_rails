set :stage, :production
set :branch, 'master'

set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"
set :server_name, '178.79.152.32'

server '178.79.152.32', user: 'root', roles: %w{web app db}, primary: true

set :deploy_to, "/var/www/#{fetch(:full_app_name)}"
set :rails_env, :production
set :enable_ssl, true

#   set :ssh_options, {
#     keys: %w(/home/m/.ssh/github/id_rsa),
#     forward_agent: true,
#     auth_methods: %w(password)
#   }
