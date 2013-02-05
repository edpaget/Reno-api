class UsersController < ApplicationController
  def index
    render json: current_user.as_json
  end
end
