class HomeController < ApplicationController
  require 'open-uri'
  # before_action :twitter_client
  def index
    if session[:user_id].nil?
      redirect_to action: 'login'
    else
      @user = User.find(session[:user_id])
      @client = twitter_client

      @search_url = URI.escape("https://twitter.com/#{@user.nickname}")

      @first_twi_id = @client.user_timeline.first.id

      uri = URI.parse("https://twitter.com/i/profiles/show/#{@user.nickname}/timeline/tweets?include_available_features=1&include_entities=1&max_position=#{@first_twi_id}&reset_error_state=false")
      @twi_json = Net::HTTP.get(uri)
      @twi_result = JSON.parse(@twi_json)

      # @oembed_tweets = Array.new
      # @doc.css('p,js-tweet-text').each_with_index do |li, index|
      #   tweet_id = li['data-item-id']
      #
      #   if tweet_id
      #     @oembed_tweets.push(@twitter_client.oembed(tweet_id).html)
      #   end
      # end

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
