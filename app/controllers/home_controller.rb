class HomeController < ApplicationController
  require 'open-uri'
  # before_action :twitter_client
  def index
    if session[:user_id].nil?
      redirect_to action: 'login'
    else
      @user = User.find(session[:user_id])
      @client = twitter_client
    end
  end

  def tweet
    @user = User.find(session[:user_id])
    @client = twitter_client

    @search_count = @client.user.tweets_count / 20

    @first_twi_id = @client.user_timeline.first.id

    @uri = URI.parse("https://twitter.com/i/profiles/show/#{@user.nickname}/timeline/tweets?include_available_features=1&include_entities=1&max_position=#{@first_twi_id}&reset_error_state=false")
    @twi_result = JSON.parse(Net::HTTP.get(@uri))

    @twi_items = @twi_result["items_html"]
    @twi_ids = @twi_items.scan(/data-tweet-id="(.+)"/)
    @twi_ids.flatten!

    @search_count.times do |i|
      @twi_id_to_url = @twi_ids.last
      @uri = URI.parse("https://twitter.com/i/profiles/show/#{@user.nickname}/timeline/tweets?include_available_features=1&include_entities=1&max_position=#{@twi_id_to_url}&reset_error_state=false")
      @twi_result = JSON.parse(Net::HTTP.get(@uri))
      @twi_items = @twi_result["items_html"]
      @twi_ids.push(@twi_items.scan(/data-tweet-id="(.+)"/))
      @twi_ids.flatten!
      sleep(0.1)
      if i >= 80
        break
      end
    end

    tweet_text = @client.status(@twi_ids.sample)

    @client.update!("#{tweet_text.text} \n#{tweet_text.created_at.strftime("%Y/%m/%d")}　#おもいだしったー")

    flash[:success] = "ツイートしました"
    redirect_to root_url
  end

  def login
  end

  private

  def twitter_client
    Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.secrets.twitter_api_key
      config.consumer_secret = Rails.application.secrets.twitter_api_secret
      config.access_token = @user.oauth_token
      config.access_token_secret = @user.oauth_token_secret
    end
  end
end
