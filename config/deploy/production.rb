set :stage, :production
set :branch, 'master'

set :full_app_name, "#{fetch(:application)}_#{fetch(:stage)}"
set :server_name, '178.79.152.32'

server '178.79.152.32', user: 'deploy', roles: %w{web app db}, primary: true

set :deploy_to, "/home/#{fetch(:deploy_user)}/apps/#{fetch(:full_app_name)}"

# dont try and infer something as important as environment from
# stage name.
set :rails_env, :production

# whether we're using ssl or not, used for building nginx
# config file
set :enable_ssl, true


#   set :ssh_options, {
# #    keys: %w(/home/rlisowski/.ssh/id_rsa),
#     forward_agent: true,
# #    auth_methods: %w(password)
#   }
