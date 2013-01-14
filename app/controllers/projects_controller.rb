class ProjectsController < ApplicationController
  def index
    if logged_in?
      @projects = @current_user.projects
      render json: @projects.as_json(:include => :last_commit)
    else
      not_authorized
    end
  end

  def show
    @project = Project.find params[:id].to_i
    render json: @project.as_json(:include => :last_commit)
  end

  def create
    if params.has_key? :payload
      @project = Project.update_from_webhook params[:payload]
      head :ok
    elsif logged_in?
      @project = Project.from_post params
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
        @project.build_project
        head :ok
      else
        not_authorized
      end
    else
      not_authorized
    end
  end

end
