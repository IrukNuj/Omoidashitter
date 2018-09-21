class HomeController < ApplicationController
  def index
    if session[:user_id].nil?
      redirect_to action:'login'
    else
      @user = User.find(session[:user_id])
    end
  end

  def login
  end



end
