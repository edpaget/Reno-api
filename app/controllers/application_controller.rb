class ApplicationController < ActionController::API
  before_filter :set_headers
  before_filter :current_user
  helper_method :current_user

  def cors
    head :ok if request.request_method == 'OPTIONS'
  end

  private

  def allowed? origin
    [ 'localhost:3333',
      'localhost:3020',
      '0.0.0.0:3333',
      'build.zooniverse.org' ].map { |location| "http://#{location}" }.include? origin
  end

  def set_headers
    if (request.headers["HTTP_ORIGIN"]) and (allowed? request.headers["HTTP_ORIGIN"])
      headers['Access-Control-Allow-Origin'] = request.headers['HTTP_ORIGIN']
      headers['Access-Control-Allow-Credentials'] = 'true'
      headers['Access-Control-Allow-Methods'] = %w(GET POST PUT DELETE OPTIONS)
      headers['Access-Control-Allow-Headers'] = %w(Origin Accept Content-Type X-Requested-With)
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def set_session
    session[:user_id] = @current_user.id
  end

  def logged_in?
    !session[:user_id].nil?
  end
end
