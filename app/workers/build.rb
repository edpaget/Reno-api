require 'fileutils'

class Build
  @queue = :builds

  def self.perform deploy_id, user_id
    deploy = Deploy.find deploy_id
    user = User.find user_id
    project = deploy.project

    @s3 = AWS::S3.new
    deploy_remote_path = "zookeeper/#{project.name}/#{deploy.git_ref}.tar.gz"
    deploy_local_path = "#{ Rails.root }/tmp/deploy/deploy.tar.gz"
    File.open(deploy_local_path, 'wb') do |file|
      file.write @s3.buckets['ubret'].objects[deploy_remote_path].read
    end

    old_dir = Dir.pwd
    Dir.chdir "#{ Rails.root }/tmp/deploy"
    `tar -xzf #{deploy_local_path}`
    extract_dir = Dir['**/*'].select{ |path| File.directory? path}.first
    Dir.chdir old_dir

    output = build_project project.build_step, extract_dir
    if $?.success?
      message = Message.from_build "Successfully built #{project.name}", output, user, project
      begin
        upload_to_s3 project.s3_bucket, extract_dir, project.build_dir
      rescue
        message = Message.from_build "Failed to Deploy #{project.name}", $!, user, project
        return
      end
      message = Message.from_build "Successfully deployed #{project.name}", '', user, project
      FileUtils.rm_rf(extract_dir)
      project.update_deploy_status deploy
      deploy.build_time = Time.now
      deploy.save!
    else
      message = Message.from_build "Failed to build #{project.name}", output, user, project
    end
  end

  def self.build_project build_step, extract_dir
    deploy_dir = "#{Rails.root}/tmp/deploy/#{extract_dir}" 
    output = String.new
    IO.popen(["npm", "install", ".", :chdir => deploy_dir, :err => [:child, :out]]) do |process|
      output.concat process.read
    end
   
    if $?.success? 
      IO.popen([build_step, :chdir => deploy_dir, :err => [:child, :out]]) do |process|
        puts 'building'
        puts process.read
        output.concat process.read
      end
    end
    output
  end

  def self.upload_to_s3 bucket_name, extract_dir, build_dir
    bucket = @s3.buckets[bucket_name]

    Dir.chdir "#{ Rails.root }/tmp/deploy/#{extract_dir}/#{build_dir}"
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

      bucket.objects[file].write file: file, acl: :public_read, content_type: content_type
    end

    bucket.objects['index.html'].write file: 'index.html', acl: :public_read, content_type: 'text/html', cache_control: 'no-cache, must_revalidate'
  end
end