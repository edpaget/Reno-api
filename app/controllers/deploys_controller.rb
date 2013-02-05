class DeploysController < ApplicationController
  skip_before_filter :logged_in, only: [:index, :show]
  def index
    @deploys = Deploy.where "project_id = ?", params[:project_id].to_i
    render json: @deploys.as_json
  end

  def show
    @deploy = Deploy.find params[:id].to_i
    render json: @deploy.as_json
  end

  def build
    @deploy = Deploy.find params[:deploy_id].to_i
    if @deploy.project.owner? @current_user
      @deploy.build_deploy @current_user
      head :ok
    else
      not_authorized
    end
  end
end
