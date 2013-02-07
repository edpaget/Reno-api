class ProjectsController < ApplicationController
  skip_before_filter :logged_in, :only => [:show, :webhook]

  def index
    @projects = @current_user.projects
    render json: @projects.as_json(:include => [:last_commit, :active_deploy])
  end

  def show
    @project = Project.find params[:id].to_i
    render json: @project.as_json(:include => [:last_commit, :active_deploy])
  end

  def create
    @project = Project.from_post params, @current_user
    render json: @project.as_json(:include => :last_commit)
  end

  def update
    @project = Project.find params[:id].to_i 
    if @project.owner? @current_user
      @project.update_from_params params, @current_user
      render json: @project.as_json(:include => :last_commit)
    else
      not_authorized
    end
  end

  def destroy
    @project = Project.find params[:id].to_i
    if @project.owner? @current_user
      @project.destroy
      head :ok
    else
      not_authorized
    end
  end

  def build
    @project = Project.find params[:project_id].to_i
    if @project.owner? @current_user
      @project.build_project @current_user
      head :ok
    else
      not_authorized
    end
  end

  def webhook
    Project.update_from_webhook params
    head :ok
  end

  def last_commit
    @project = Project.find params[:project_id].to_i
    if @project.owner? @current_user
      @project.retrieve_last_commit @current_user
      head :ok
    else
      not_authorized
    end
  end

end
