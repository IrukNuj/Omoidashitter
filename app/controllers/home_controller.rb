class HomeController < ApplicationController
  require 'open-uri'
  # before_action :twitter_client

  def index
    if session[:user_id].nil?
      redirect_to action: 'login'
    else
      @user = User.find(session[:user_id])
      @client = twitter_client
      # リソース確認用
      @res = Twitter::REST::Request.new(@client, :get, '/1.1/application/rate_limit_status.json').perform
    end
  end

  def show
    if session[:user_id].nil?
      redirect_to action: 'login'
    else
      @user = User.find(session[:user_id])
      @client = twitter_client
      if session[:tweet_items].nil?
        session[:tweet_items] = Array.new if session[:tweet_items].nil?

        search_times = @client.user.statuses_count / 200
        puts "search_count = #{search_times}" # デバッグ用

        search_times.times do |i|
          if @tweets_last_id
            tweets = @client.user_timeline(count: 200,max_id: @tweets_last_id)
          else
            tweets = @client.user_timeline(count: 200)
          end

          @tweets_last_id = tweets.last.id
          tweet_sample = tweets.sample
          session[:tweet_items].push('time' => tweet_sample.created_at ,'text' => tweet_sample.text)
          break if i >= 20 # APIリミッタ用のbreak if
          puts session[:tweet_items].last# デバッグ用
        end
      end

      update_tweet = session[:tweet_items].sample
      puts update_tweet # デバッグ用

      # 以下つぶやき用
      @update_tweet_text = update_tweet['text'].truncate(120, omission: '...')
      @update_tweet_date = update_tweet['time'].to_s[0,10]
      @update_text = "#{@update_tweet_text} \r\n#{@update_tweet_date}"
    end
  end

  def new
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
