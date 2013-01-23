env = ENV['RAILS_ENV'] || 'development'

worker_processes 2
working_directory '/rails/apps/reno/current'
preload_app true

timeout 30

pid "/rails/app/reno/current/tmp/pids/unicord/pid"
stderr_path "/rails/app/reno/current/log/unicorn.stderr.log"
stdout_path "/rails/app/reno/current/log/unicorn.stdout.log"

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and
    ActiveRecord::Base.establish_connection
end