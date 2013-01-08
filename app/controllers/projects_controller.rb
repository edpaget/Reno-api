class ProjectsController < ApplicationController
  def index
    @projects = Project.find :all
    render json: @projects.as_json(:include => :deploys)
  end

  def show
    @project = Project.find params[:id].to_i
    render json: @project.as_json(:include => :deploys)
  end

  def create
    if params.has_key? :payload
      Project.from_github_webhook params[:payload]
      head :ok
    end
  end

  def update
    @project = Project.find params[:id].to_i

    if params.has_key? :payload
      @project.update_from_webhook params[:payload]
    else
      @project.update_from_params params
    end

    render json: @project.as_json(:include => :deploys)
  end

  def destroy
    @project = Project.find params[:id].to_i
    @project.destroy
    head :ok
  end

  def build
    @project = Project.find params[:project_id].to_i
    @project.build_project
    head :ok
  end

end
