Rails.application.config.middleware.use OmniAuth::Builder do
  if Rails.env.production?
    github_yaml = YAML.load_file("#{ Rails.root }/config/github_api.yml")['production']
    provider :github, github_yaml['key'], github_yaml['secret'], scope: 'repo,user'
  else
    provider :github, ENV['ZOO_BUILD_GITHUB_KEY'], ENV['ZOO_BUILD_GITHUB_SECRET'], scope: 'repo,user'
  end
end