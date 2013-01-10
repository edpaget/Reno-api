Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['ZOO_BUILD_GITHUB_KEY'], ENV['ZOO_BUILD_GITHUB_SECRET'], scope: 'repo,user'
end