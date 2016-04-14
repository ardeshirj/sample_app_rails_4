# Pusher controller
class CookiesController < ApplicationController
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session,
                       if: proc { |c| c.request.format == 'application/json' }

  def auth
    if current_user
      response = Pusher[params[:channel_name]].authenticate(
        params[:socket_id],
        user_id: current_user.id,
        user_info: { login_time: Time.now.to_formatted_s(:number) }
      )
      render json: response
    else
      render text: 'Forbidden', status: '403'
    end
  end
end
