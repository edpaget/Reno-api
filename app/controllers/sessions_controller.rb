class SessionsController < ApplicationController
  skip_before_filter :logged_in?

  def create
    @current_user = User.find_or_create_from_omniauth auth_hash
    set_session
    redirect_to "http://reno.zooniverse.org"
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

end
