class SessionsController < ApplicationController
  def create
    user = User.find_or_create_from_auth(request.env['omniauth.auth'])
    session[:user_id] = user.id
    # ToDo 直す　絶対やること
    session[:oauth_token] = user.oauth_token
    session[:oauth_token_secret] = user.oauth_token_secret

    redirect_to root_url
  end

  def destroy
    reset_session
    redirect_to root_url
  end
end
