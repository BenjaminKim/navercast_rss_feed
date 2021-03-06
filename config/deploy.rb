# config valid only for current version of Capistrano
# lock '3.8.0'

set :application, 'navercast_feed'
set :repo_url, 'git@github.com:BenjaminKim/navercast_feed.git'

# Default branch is :master
ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call
#set :branch, 'master'
set :rails_env, 'production'

# Default deploy_to directory is /var/www/my_app
set :deploy_to, '/home/deploy/navercast_feed'

# Default value for :format is :pretty
#set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
set :linked_dirs, %w{log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }
set :default_env, { rvm_bin_path: '~/.rvm/bin' }
set :keep_releases, 15
