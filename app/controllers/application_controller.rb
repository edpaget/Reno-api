class ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods

  before_filter :set_headers
  before_filter :current_user
  before_filter :logged_in

  helper_method :current_user
  helper_method :not_authorized

  def cors
    head :ok if request.request_method == 'OPTIONS'
  end

  private

  def allowed? origin
    [ 'localhost:3333',
      'localhost:3020',
      '0.0.0.0:3333',
      'reno.zooniverse.org',
      'zooniverse-demo.s3.amazonaws.com' ].map { |location| "http://#{location}" }.include? origin
  end

  def set_headers
    if (request.headers["HTTP_ORIGIN"]) and (allowed? request.headers["HTTP_ORIGIN"])
      headers['Access-Control-Allow-Origin'] = request.headers['HTTP_ORIGIN']
      headers['Access-Control-Allow-Credentials'] = 'true'
      headers['Access-Control-Allow-Methods'] = %w(GET POST PUT DELETE OPTIONS).join ", "
      headers['Access-Control-Allow-Headers'] = %w(Origin Accept Content-Type X-Requested-With).join ", "
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def set_session
    session[:user_id] = @current_user.id
  end

  def logged_in
    session? || token?
  end

  def token?
    authenticate_or_request_with_http_token do |key, options|
      @current_user = User.by_reno_token key if User.exists? reno_token: key
    end
    !@current_user.nil?
  end

  def session?
    !session[:user_id].nil?
  end

  def not_authorized
    render json: { :status => "Not Authorized" }.as_json, :status => 401
  end
end
