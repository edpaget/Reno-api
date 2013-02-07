class UsersController < ApplicationController
  def index
    render json: current_user.as_json
  end

  def signout
    reset_session
    head :ok
  end
end
