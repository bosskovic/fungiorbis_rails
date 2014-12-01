lock '3.2.1'

set :application, 'fungiorbis_rails'
set :deploy_user, 'root'

set :scm, :git
set :repo_url, "git@github.com:bosskovic/#{fetch(:application)}.git"

set :rvm_type, :auto
set :rvm_ruby_version, '2.1.5'

set :format, :pretty
set :log_level, :debug

set :pty, true

set :linked_files, %w{config/database.yml config/secrets.yml}
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

set :keep_releases, 3

set :tests, []

set(:config_files, %w(
  database_example.yml
  secrets_example.yml
  nginx.conf
  log_rotation
))

set(:executable_config_files, [])

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
  after :finishing, 'deploy:cleanup'

  # remove the default nginx configuration as it will tend to conflict with our configs.
  before 'deploy:setup_config', 'nginx:remove_default_vhost'

  # reload nginx to it will pick up any modified vhosts from setup_config
  after 'deploy:setup_config', 'nginx:reload'

  # Restart monit so it will pick up any monit configurations we've added
  after 'deploy:setup_config', 'monit:restart'

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :mkdir, '-p', "#{ release_path }/tmp"
      execute :touch, release_path.join('tmp/restart.txt')
      execute :touch, release_path.join('Gemfile')
    end
  end
  after :publishing, :restart
end