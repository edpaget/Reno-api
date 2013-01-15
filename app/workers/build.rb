class Build
  @queue = :builds

  def self.perform deploy_id
    deploy = Deploy.find deploy_id
    project = Deploy.project

    @s3 = AWS::S3.new
    deploy_remote_path = "zookeeper/#{project.name}/#{deploy.git_ref}.tar.gz"
    deploy_local_path = "#{ Rails.root }/tmp/deploy/deploy.tar.gz"
    File.open(deploy_path, 'wb') do |file|
      file.write @s3.buckets['ubret'].objects[deploy_remote_path].read
    end

    build_project project.build_step
    if $?.success?
      upload_to_s3
    else
      # send message to user
    end
  end

  def self.build_project build_step
    deploy_dir = "#{Rails.root}/tmp/deploy" 
    output = String.new
    IO.popen([build_step, :chdir => deploy_dir, :err => [:child, :out]]) do |process|
      output = process.read
    end
  end

  def self.upload_to_s3 bucket_name, build_dir
    bucket = s3.buckets[bucket_name]

    Dir.chdir "#{ Rails.root }/tmp/deploy/#{build_dir}"
    to_upload = Dir['**/*'].reject{ |path| File.directory? path }
    to_upload.delete 'index.html'

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

      bucket.objects[file].write file: file, alc: :public_read, content_type: content_type
    end

    bucket.objects['index.html'].write file: 'index.html', acl: :public_read, content_type: 'text/html', cache_control: 'no-cache, must_revalidate'
  end
end