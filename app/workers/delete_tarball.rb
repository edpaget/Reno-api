class DeleteTarball
  @queue = :delete_tarball

  def self.perform project_name, git_ref
    s3 = AWS::S3.new
    s3.buckets['ubret'].objects["zookeeper/#{project_name}/#{git_ref}.tar.gz"].delete
  end
end