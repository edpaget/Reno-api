class Build
  @queue = :builds

  def self.perform deploy_id, bucket, build_step, build_dir, git_url
    deploy = Deploy.find deploy_id
    Dir.chdir Rails.root

    download = <<-BASH
    mkdir tmp/deploy
    cd tmp/deploy
    git init
    git remote add origin #{git_url}
    git fetch origin #{deploy.git_ref}
    git reset --hard FETCH_HEAD
    BASH
    system download

    build_project build_step
    upload_to_s3 bucket, build_dir
    Dir.chdir Rails.root
    `rm -rf tmp/deploy/`
  end

  def self.build_project build_step
    Dir.chdir Rails.root

    build =<<-BASH
    cd tmp/deploy
    #{build_step}
    BASH

    system build
  end

  def self.upload_to_s3 bucket_name, build_dir
    s3 = AWS::S3.new
    bucket = s3.buckets[bucket_name]

    Dir.chdir build_dir
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