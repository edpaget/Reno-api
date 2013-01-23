Resque::Server.use(Rack::Auth::Basic) do |user, password|
  settings = YAML.load_file("#{Rails.root}/config/resque_auth.yml")[Rails.env]
  (user == settings['username']) && (password == settings['password'])
end