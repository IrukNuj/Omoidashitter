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

    if session[:tweet_items].nil?
      if session[:tweet_items].nil?
        session[:tweet_items] = Array.new
      end
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
        session[:tweet_items].push(@twi_ids.sample)
        sleep(0.05)
        if i >= 80
          break
        end
      end
    end

    @tweet_uri = Net::HTTP.get(URI.parse("https://twitter.com/#{@user[:nickname]}/status/#{session[:tweet_items].sample}"))
    @tweet_text = @tweet_uri.force_encoding("UTF-8").scan(/<p class="TweetTextSize TweetTextSize--jumbo js-tweet-text tweet-text" lang="ja" data-aria-label-part="0">(.+)<\/p>/)[0][0]
    @tweet_date = @tweet_uri.force_encoding("UTF-8").scan(/<span>.*(\d{4}年\d{1,2}月\d{1,2}日)<\/span>/)[0][0]

    @tweet_text = CGI.unescapeHTML(@tweet_text)
    @tweet_text_link_excluded = @tweet_text.gsub(/<.*?>/,"").gsub(/<\/a>/,"")


    @update_tweet_text = @tweet_text_link_excluded.truncate(110, omission: '...')
    @update_text = "#{@update_tweet_text}　\r\n#{@tweet_date}"
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
