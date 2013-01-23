env = ENV['RAILS_ENV'] || 'development'

worker_processes 2
working_directory '/rails/apps/reno/current'
listen '/tmp/reno.socket', :backlog => 64
preload_app true

timeout 30

pid "/rails/apps/reno/current/tmp/pids/unicorn.pid"
stderr_path "/rails/apps/reno/current/log/unicorn.stderr.log"
stdout_path "/rails/apps/reno/current/log/unicorn.stdout.log"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end