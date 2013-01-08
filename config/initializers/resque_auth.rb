Resque::Server.use(Rack::Auth::Basic) do |user, password|
  if Rails.env.development? || Rails.env.test?
    (user == 'user') && (password == 'password')
  else
    (user == ENV['resque_user']) && (password == ENV['resque_password'])
  end
end