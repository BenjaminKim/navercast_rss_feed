app_dir = '/home/ubuntu/navercast_feed'

worker_processes 6
working_directory app_dir + '/current'

# Load app into the master before forking workers for super-fast
# worker spawn times
preload_app true

# nuke workers after 30 seconds (60 is the default)
timeout 40

# Listen on a Unix data socket
listen "#{app_dir}/shared/tmp/sockets/unicorn.socket", backlog: 256
listen '127.0.0.1:3006'

pid "#{app_dir}/shared/tmp/pids/unicorn.pid"
stderr_path "#{app_dir}/shared/log/unicorn.stderr.log"
stdout_path "#{app_dir}/shared/log/unicorn.stdout.log"

before_exec do |server|
  ENV['BUNDLE_GEMFILE'] = app_dir + '/current/Gemfile'
end

before_fork do |server, worker|
  # the following is highly recomended for Rails + "preload_app true"
  # as there's no need for the master process to hold a connection
  # defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  ##
  # When sent a USR2, Unicorn will suffix its pidfile with .oldbin and
  # immediately start loading up a new version of itself (loaded with a new
  # version of our app). When this new Unicorn is completely loaded
  # it will begin spawning workers. The first worker spawned will check to
  # see if an .oldbin pidfile exists. If so, this means we've just booted up
  # a new Unicorn and need to tell the old one that it can now die. To do so
  # we send it a QUIT.
  #
  # Using this method we get 0 downtime deploys.

  old_pid = "#{server.config[:pid]}.oldbin"

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
  sleep 1
end

after_fork do |server, worker|
  # Unicorn master loads the app then forks off workers - because of the way
  # Unix forking works, we need to make sure we aren't using any of the parent's
  # sockets, e.g. db connection

  # defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
  # Redis and Memcached would go here but their connections are established
  # on demand, so the master never opens a socket

  #rails_root = ENV['Rails.root'] || File.dirname(__FILE__) + '/../..'
end
