class GithubCommit
  @queue = :github_commit

  def self.perform user, project
    client = Octokit::Client.new :login => user.github_username, :oauth_token => user.oauth_token
    commits = client.commits project.name, project.branch
    project.update_last_commit commits.first[:commit]
  end
end
