class BrunchBuild < Build
  def self.perform
    dir = super
    build_project dir
    upload_to_s3 @project.s3_bucket, dir, 'public/'
  end

  def self.build_project dir
    old_dir = Dir.pwd 
    Dir.chdir "#{ Rails.root }/tmp/deploy/#{dir}"
    build_process = <<-BASH
      echo 'building application...'
      mkdir public

      npm install .
      brunch build -o

      timestamp=`date -u +%Y-%m-%d_%H-%M-%S`

      echo 'build timestamps...'
      mv public/javascripts/app.js "public/javascripts/app-$timestamp.js"
      mv public/javascripts/vendor.js "public/javascripts/vendor-$timestamp.js"
      mv public/stylesheets/app.css "public/stylesheets/app-$timestamp.css"
      mv public/stylesheets/vendor.css "public/stylesheets/vendor-$timestamp.css"

      echo 'compress assets...'
      gzip -9 -c "public/javascripts/app-$timestamp.js" > "public/javascripts/app-$timestamp.js.gz"
      gzip -9 -c "public/javascripts/vendor-$timestamp.js" > "public/javascripts/vendor-$timestamp.js.gz"
      gzip -9 -c "public/stylesheets/app-$timestamp.css" > "public/stylesheets/app-$timestamp.css.gz"
      gzip -9 -c "public/stylesheets/vendor-$timestamp.css" > "public/stylesheets/vendor-$timestamp.css.gz"

      mv public/index.html public/index.old.html
      sed "s/app\.\([a-z]*\)/app-$timestamp.\1/g;s/vendor\.\([a-z]*\)/vendor-$timestamp.\1/g" <public/index.old.html > public/index.html
      rm public/index.old.html
      echo 'build successful!'
    BASH

    output = 
  end

end
end
