class ProjectsController < ApplicationController
  def index
    if logged_in?
      @projects = @current_user.projects
      render json: @projects.as_json(:include => [:last_commit, :active_deploy])
    else
      not_authorized
    end
  end

  def show
    @project = Project.find params[:id].to_i
    render json: @project.as_json(:include => :last_commit)
  end

  def create
    if logged_in?
      @project = Project.from_post params, @current_user
      render json: @project.as_json(:include => :last_commit)
    else
      not_authorized
    end
  end

  def update
    if logged_in?
      @project = Project.find params[:id].to_i 
      if @project.owner? @current_user
        @project.update_from_params params
        render json: @project.as_json(:include => :last_commit)
      else
        not_authorized
      end
    else
      not_authorized
    end
  end

  def destroy
    if logged_in?
      @project = Project.find params[:id].to_i
      if @project.owner? @current_user
        @project.destroy
        head :ok
      else
        not_authorized
      end
    else
      not_authorized
    end
  end

  def build
    if logged_in?
      @project = Project.find params[:project_id].to_i
      if @project.owner? @current_user
        @project.build_project @current_user
        head :ok
      else
        not_authorized
      end
    else
      not_authorized
    end
  end

  def webhook
    Project.update_from_webhook params
    head :ok
  end

end
