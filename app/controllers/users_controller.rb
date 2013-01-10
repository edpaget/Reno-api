class UsersController < ApplicationController
  def index
    if logged_in?
      render json: current_user.as_json
    else
      render json: { :status => "Not Authorized" }.as_json, :status => 401
    end
  end
end
