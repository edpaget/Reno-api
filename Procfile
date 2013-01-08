web: bundle exec rails server thin -p $PORT -e $RACK_ENV
resque: bundle exec rake environment resque:work PIDFILE=tmp/pids/resque.pid QUEUE=*