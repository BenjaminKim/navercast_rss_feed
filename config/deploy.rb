#config valid only for Capistrano 3.1

set :application, 'navercast_feed'
set :repo_url, 'git@github.com:BenjaminKim/navercast_feed.git'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
#set :branch, 'master'
set :rails_env, 'production'

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/var/www/navercast_feed'

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :info

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, { rvm_bin_path: '~/.rvm/bin' }

set :keep_releases, 5
set :unicorn_rack_env, :production
after 'deploy:publishing', 'unicorn:restart'
