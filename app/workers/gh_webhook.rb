class GithubWebhook
  @queue = :github_webhook

  def self.perform user, repo_name
    client = Octokit::Client.new :login => user.github_username, :oauth_token => user.oauth_token
    url = { :url => "http://zoo-build.herokuapp.com", :content_type => 'json' }
    hooks = { :events => %w(push), :active => true }
    client.create_hook repo_name, 'web', url, hooks
  end
end