# config valid only for Capistrano 3.1
lock '3.2.1'

set :application, 'fungiorbis_rails'
set :deploy_user, 'deploy'

set :scm, :git
set :repo_url, "git@github.com:bosskovic/#{fetch(:application)}.git"

set :rvm_type, :user
set :rvm_ruby_version, '2.1.5' # Defaults to: 'default'

set :format, :pretty
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

set :keep_releases, 3

set :tests, []

set(:config_files, %w(
  nginx.conf
  log_rotation
  monit
))

# set(:executable_config_files, %w(
#   passenger_init.sh
# ))

set(:symlinks, [
    {
        source: 'nginx.conf',
        link: "/etc/nginx/sites-enabled/#{fetch(:full_app_name)}"
    },
    {
        source: 'log_rotation',
        link: "/etc/logrotate.d/#{fetch(:full_app_name)}"
    },
    {
        source: 'monit',
        link: "/etc/monit/conf.d/#{fetch(:full_app_name)}.conf"
    }
])


namespace :deploy do
  # make sure we're deploying what we think we're deploying
  before :deploy, 'deploy:check_revision'
  # only allow a deploy with passing tests to deployed
  before :deploy, 'deploy:run_tests'
  # compile assets locally then rsync
  after 'deploy:symlink:shared'  #, 'deploy:compile_assets_locally'
  after :finishing, 'deploy:cleanup'

  # remove the default nginx configuration as it will tend
  # to conflict with our configs.
  before 'deploy:setup_config', 'nginx:remove_default_vhost'

  # reload nginx to it will pick up any modified vhosts from
  # setup_config
  after 'deploy:setup_config', 'nginx:reload'

  # Restart monit so it will pick up any monit configurations
  # we've added
  after 'deploy:setup_config', 'monit:restart'

  # As of Capistrano 3.1, the `deploy:restart` task is not called
  # automatically.
  after 'deploy:publishing', 'deploy:restart'
end