class UsersController < ApplicationController
  def index
    if logged_in?
      render json: current_user.as_json
    else
      not_authorized
    end
  end
end
