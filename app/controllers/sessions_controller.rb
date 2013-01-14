class SessionsController < ApplicationController
  def create
    @current_user = User.find_or_create_from_omniauth auth_hash
    set_session
    redirect_to '/'
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

end