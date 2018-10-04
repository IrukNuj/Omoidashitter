class HomeController < ApplicationController
  require 'open-uri'
  # before_action :twitter_client

  def index
    if session[:user_id].nil?
      redirect_to action: 'login'
    else
      @user = User.find(session[:user_id])
    end
  end


  def tweet
    if session[:user_id].nil?
      redirect_to action: 'login'
    else
      @user = User.find(session[:user_id])

      tweet_search

      # テキストと時刻がちゃんと取得できるまでIDを回す
      loop do
        @tweet_uri = Net::HTTP.get(URI.parse("https://twitter.com/#{@user[:nickname]}/status/#{session[:tweet_items].sample}"))
        @tweet_text = @tweet_uri.force_encoding("UTF-8").scan(/<p class="TweetTextSize TweetTextSize--jumbo js-tweet-text tweet-text".+>(.+)<\/p>/)
        unless @tweet_text.empty?
          @tweet_date = @tweet_uri.force_encoding("UTF-8").scan(/<span>.*(\d{4}年\d{1,2}月\d{1,2}日)<\/span>/)
          unless @tweet_date.empty?
            break
          end
        end
      end

      # 配列やダブルクオーテーションを処理
      @tweet_text = CGI.unescapeHTML(@tweet_text[0][0])
      @tweet_date_text = @tweet_date[0][0]

      # スクレイピングの都合で発生した各タグを処理。正規表現抜きで処理できるならしたい。
      @tweet_text_link_excluded = @tweet_text.gsub(/<.*?>/, "").gsub(/<\/a>/, "")

      # 文字数制限。
      @update_tweet_text = @tweet_text_link_excluded.truncate(120, omission: '...')
      @update_text = "#{@update_tweet_text} \r\n#{@tweet_date_text}"
    end
  end


  def login
  end

  private

  def tweet_search
    @user = User.find(session[:user_id])
    @client = twitter_client

    # sessionにツイートデータが無ければ、ツイート取得クローラ走らせてちょびちょびsessionに保存
    if session[:tweet_items].nil?
      if session[:tweet_items].nil?
        session[:tweet_items] = Array.new
      end
      @search_count = 2000 / 70      #35がいいよー！
      @first_twi_id = "1047760333253763072"

      @uri = URI.parse("https://twitter.com/i/profiles/show/#{@user.nickname}/timeline/tweets?include_available_features=1&include_entities=1&max_position=#{@first_twi_id}&reset_error_state=false")
      @twi_result = JSON.parse(Net::HTTP.get(@uri))

      @twi_items = @twi_result["items_html"]
      @twi_ids = @twi_items.scan(/data-tweet-id="(.+)"/)
      @twi_ids.flatten!

      @search_count.times do |i|
        @uri = URI.parse("https://twitter.com/i/profiles/show/#{@user.nickname}/timeline/tweets?include_available_features=1&include_entities=1&max_position=#{@twi_ids.last}&reset_error_state=false")
        @twi_result = JSON.parse(Net::HTTP.get(@uri))
        @twi_items = @twi_result["items_html"]
        twi_items_scaned = @twi_items.scan(/data-tweet-id="(.+)"/)
        if i * 1.5 >= @search_count
          session[:tweet_items].push(twi_items_scaned.sample)
        end
        session[:tweet_items].flatten!
        puts session[:tweet_items].last
        @twi_ids.push(twi_items_scaned)
        @twi_ids.flatten!
        # session[:tweet_items].push(@twi_ids.sample)

        # 実装時には死んでも消さないこと
        sleep(0.3)
        if i >= 40
          break
        end
      end

    end
  end

  def twitter_client
    Twitter::REST::Client.new do |config|
      config.consumer_key = Rails.application.secrets.twitter_api_key
      config.consumer_secret = Rails.application.secrets.twitter_api_secret
      config.access_token = @user.oauth_token
      config.access_token_secret = @user.oauth_token_secret
    end
  end
end
