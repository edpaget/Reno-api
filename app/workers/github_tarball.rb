require 'open-uri'

class GithubTarball
  @queue = :github_tarball

  def self.perform user_id, project_id
    user = User.find user_id.to_i
    project = Project.find project_id.to_i

    repo_name = project.name
    git_ref = project.last_commit.git_ref

    client = Octokit::Client.new :login => user.github_username, :oauth_token => user.oauth_token
    tarball_url = client.archive_link repo_name, :ref => git_ref
    puts tarball_url
    download git_ref, tarball_url, repo_name
  end

  def self.download ref, url, repo_name
    download_path = "#{ Rails.root }/tmp/#{ref}.tar.gz"
    open(url, 'rb') do |tar|
      File.open(download_path, "wb") do |file|
        file.write(tar.read)
      end
    end
    upload ref, download_path, repo_name
  end

  def self.upload ref, path, repo_name
    s3_client = AWS::S3.new
    bucket = s3_client.buckets['ubret']

    file_name = "zookeeper/#{repo_name}/#{ref}.tar.gz"
    bucket.objects[file_name].write :file => path
    File.delete path
  end
end