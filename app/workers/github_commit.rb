class GithubCommit
  @queue = :github_commit

  def self.perform user_id, project_id
    user = User.find user_id
    project = Project.find project_id

    client = Octokit::Client.new :login => user.github_username, :oauth_token => user.oauth_token
    commits = client.commits project.name, project.branch
    project.update_last_commit commits.first[:commit]
  end
end
