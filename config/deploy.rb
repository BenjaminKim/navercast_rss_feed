set :application, 'navercast_feed'
set :repo_url, 'git@github.com:BenjaminKim/navercast_feed.git'
set :branch, 'master'
set :rails_env, 'production'
#ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }

set :deploy_to, '/var/www/navercast_feed'
set :scm, :git

set :format, :pretty
set :log_level, :debug
# set :pty, true

# set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets public/system}

# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :keep_releases, 5

set :unicorn_rack_env, :production

after 'deploy:publishing', 'unicorn:restart'

fetch(:default_env).merge!(rails_env: :production)