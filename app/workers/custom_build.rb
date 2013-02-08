class CustomBuild < Build
  def self.perform deploy_id, user_id
    dir = super
    build_project @project.build_step, dir
  end

  def self.build_project build_step, extract_dir
    deploy_dir = "#{Rails.root}/tmp/deploy/#{extract_dir}" 
    output = String.new
    IO.popen([build_step, :chdir => deploy_dir, :err => [:child, :out]]) do |process|
      output = process.read
    end
  end


end