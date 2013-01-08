class DeploysController < ApplicationController
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
    @deploy.build_deploy
    head :ok
  end
end
