class HomeController < ApplicationController
  # before_action :twitter_client
  def index
    if session[:user_id].nil?
      redirect_to action:'login'
    else
      @user = User.find(session[:user_id])
    end
  end

  def tweet
    @client = twitter_client
    @client.update("アプリから呟いてるよ")
    redirect_to root_url
  end

  def login
  end

  private
    def twitter_client
      Twitter::REST::Client.new do |config|
        config.consumer_key = Rails.application.secrets.twitter_api_key
        config.consumer_secret = Rails.application.secrets.twitter_api_secret
        config.access_token = session[:oauth_token]
        config.access_token_secret = session[:oauth_token_secret]
      end
    end
end
