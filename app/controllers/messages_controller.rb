class MessagesController < ApplicationController
  def index
    if logged_in?
      @messages = @current_user.messages
      render json: @messages.as_json
    else
      not_authorized
    end
  end
end
