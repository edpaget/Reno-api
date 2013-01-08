class DeploysController < ApplicationController
  def build
    @deploy = Deploy.find params[:deploy_id].to_i
    @deploy.build_deploy
    head :ok
  end
end
