class Build
  @queue = :builds
  @deploy_local_path = "#{ Rails.root }/tmp/deploy/deploy.tar.gz"

  def self.perform deploy_id, user_id
    @deploy = Deploy.find deploy_id
    @user = User.find user_id
    @project = deploy.project
    @s3 = AWS::S3.new
    download
    extract
  end

  def self.download 
    deploy_remote_path = "zookeeper/#{@project.name}/#{@deploy.git_ref}.tar.gz"
    File.open(@deploy_local_path, 'wb') do |file|
      file.write @s3.buckets['ubret'].objects[deploy_remote_path].read
    end
  end

  def self.extract
    old_dir = Dir.pwd
    Dir.chdir "#{ Rails.root }/tmp/deploy"
    `tar -xzf #{@deploy_local_path}`
    extract_dir = Dir['**/*'].select{ |path| File.directory? path}.first
    Dir.chdir old_dir
    extract_dir
  end

  def self.clean_up
    if $?.success?
      message = Message.from_build "Successfully built #{project.name}", output, user, project
      begin
        upload_to_s3 @project.s3_bucket, dir, build_dir
      rescue
        message = Message.from_build "Failed to Deploy #{project.name}", $!, user, project
      end
      message = Message.from_build "Successfully deployed #{project.name}", '', user, project
      project.update_deploy_status deploy
      deploy.build_time = Time.now
      deploy.save!
    else
      message = Message.from_build "Failed to build #{project.name}", output, user, project
    end
    `rm -rf #{"#{Rails.root}/tmp/deploy/#{extract_dir}"}`
  end

  def self.upload_to_s3 bucket_name, extract_dir, build_dir
    bucket = @s3.buckets[bucket_name]

    Dir.chdir "#{ Rails.root }/tmp/deploy/#{extract_dir}/#{build_dir}"
    to_upload = Dir['**/*'].reject{ |path| File.directory? path }

    if to_upload.include? 'index.html'
      bucket.objects['index.html'].write file: 'index.html', acl: :public_read, content_type: 'text/html', cache_control: 'no-cache, must_revalidate'
      to_upload.delete 'index.html'
    end

    to_upload.each.with_index do |file, index|
      content_type = case File.extname(file)
                     when '.html'
                       'text/html'
                     when '.js'
                       'application/javascript'
                     when '.css'
                       'text/css'
                     when '.gz'
                       'application/x-gzip'
                     when '.ico'
                       'image/x-ico'
                     else
                       `file --mime-type -b #{ file }`.chomp
                     end

      bucket.objects[file].write file: file, acl: :public_read, content_type: content_type
    end

  end
end