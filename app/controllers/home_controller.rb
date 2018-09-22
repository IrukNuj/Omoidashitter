class HomeController < ApplicationController
  # before_action :twitter_client
  def index
    if session[:user_id].nil?
      redirect_to action: 'login'
    else
      @user = User.find(session[:user_id])
      @client = twitter_client

      # @client_timeline_last = @client.user_timeline.first
      # @client_timeline = (@client.user_timeline({max_id: @client_timeline_last.id, count: 200,exclude_replies: true}))
      # tweet全取得
      # @client_timeline = Array.new
      # search_count = (@client.user.tweets_count / 200) + 1
      #
      # @client_timeline_last = @client.user_timeline.first
      #
      # search_count.times do |i|
      #   @client_timeline.push(@client.user_timeline({max_id: @client_timeline_last.id, count: 200}))
      #   @client_timeline_last = @client_timeline.last.last
      # end

    end
  end

  def tweet
    @client = twitter_client
    @client_timeline = Array.new
    search_count = @client.user.tweets_count / 200

    @client_timeline_last = @client.user_timeline.first

    search_count.times do |i|
      @client_timeline.push(@client.user_timeline({max_id: @client_timeline_last.id, count: 200}))
      @client_timeline_last = @client_timeline.last.last
      if i  >= 10
        break
      end
    end

    tweet_text = @client_timeline.last.sample
    # tweet_date = @client_timeline.sample.sample

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
      config.access_token = session[:oauth_token]
      config.access_token_secret = session[:oauth_token_secret]
    end
  end
end
