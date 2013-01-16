class DeleteTarball
  @queue = :delete_tarball

  def self.perform deploy_id
    deploy = Deploy.find deploy_id
    project = deploy.project

    s3 = AWS::S3.new
    s3.buckets['ubret'].objects["zookeeper/#{project.name}/#{deploy.git_ref}.tar.gz"].delete
  end
end