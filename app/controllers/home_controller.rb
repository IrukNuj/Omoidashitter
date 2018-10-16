class HomeController < ApplicationController
  require 'open-uri'
  # before_action :twitter_client

  def index
    if session[:user_id].nil?
      redirect_to action: 'login'
    else
      @user = User.find(session[:user_id])
      @client = twitter_client
      @res = Twitter::REST::Request.new(@client, :get, '/1.1/application/rate_limit_status.json').perform
    end
  end

  def tweet
    if session[:user_id].nil?
      redirect_to action: 'login'
    else
      @user = User.find(session[:user_id])
      @client = twitter_client
      if session[:tweet_items].nil?
        if session[:tweet_items].nil?
          session[:tweet_items] = Array.new
        end
        search_count = @client.user.statuses_count / 200
        puts "serch_count = #{search_count}"

        search_count.times do |i|
          if @twi_items_last_id
            twi_items = @client.user_timeline(count: 200,max_id: @twi_items_last_id)
          else
            twi_items = @client.user_timeline(count: 200)
          end
          @twi_items_last_id = twi_items.last.id
          twi_item_selected_random = twi_items.sample
          twi_item_selected_random_time = twi_item_selected_random.created_at
          twi_item_selected_random_text = twi_item_selected_random.text
          session[:tweet_items].push('time' => twi_item_selected_random_time ,'text' => twi_item_selected_random_text)
          if i >= 20
            break
          end
          puts session[:tweet_items].last
        end
      end
      update_tweet = session[:tweet_items].sample
      puts update_tweet

      @update_tweet_text = update_tweet['text'].truncate(120, omission: '...')
      @update_tweet_date = update_tweet['time'].to_s[0,10]
      @update_text = "#{@update_tweet_text} \r\n#{@update_tweet_date}"
    end
  end


  def login
  end

  def tweet_search_repeat
    # sessionにツイートデータが無ければ、ツイート取得クローラ走らせてちょびちょびsessionに保存
    if session[:tweet_items]
      @user = User.find(session[:user_id])
      @search_count = 20
      @first_twi_id = "#{session[:tweet_items].last}"
      session[:tweet_items_new] = Array.new
      @uri = URI.parse("https://twitter.com/i/profiles/show/#{@user.nickname}/timeline/tweets?include_available_features=1&include_entities=1&max_position=#{@first_twi_id}&reset_error_state=false")
      @twi_result = JSON.parse(Net::HTTP.get(@uri))

      @twi_items = @twi_result["items_html"]
      @twi_ids = @twi_items.scan(/data-tweet-id="(.+)"/)
      @twi_ids.flatten!

      @search_count.times do |i|
        @uri = URI.parse("https://twitter.com/i/profiles/show/#{@user.nickname}/timeline/tweets?include_available_features=1&include_entities=1&max_position=#{@twi_ids.last}&reset_error_state=false")
        @uri = URI.parse("https://twitter.com/i/profiles/show/#{@user.nickname}/timeline/tweets?include_available_features=1&include_entities=1&max_position=683636977321680896&reset_error_state=false")
        puts @uli
        @twi_result = JSON.parse(Net::HTTP.get(@uri))
        @twi_items = @twi_result["items_html"]
        twi_items_scaned = @twi_items.scan(/data-tweet-id="(.+)"/)

        if twi_items_scaned.empty?
          session[:tweet_items] = session[:tweet_items_new] if i >= 10
          flash[:tweet_limit] = "一番古いツイートまで遡りました！"
          break
        end

        session[:tweet_items_new].push(twi_items_scaned.sample)
        session[:tweet_items_new].flatten!
        puts session[:tweet_items_new].last
        @twi_ids.push(twi_items_scaned)
        @twi_ids.flatten!
        # session[:tweet_items].push(@twi_ids.sample)

        # 実装時には死んでも消さないこと
        sleep(0.5)
      end
      unless session[:tweet_items_new].empty?
        session[:tweet_items] = session[:tweet_items_new]
      end
    end

    redirect_to home_tweet_url, status: 301

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

  # def tweet_search
  #   @user = User.find(session[:user_id])
  #   @client = twitter_client
  #
  #   # sessionにツイートデータが無ければ、ツイート取得クローラ走らせてちょびちょびsessionに保存
  #   if session[:tweet_items].nil?
  #     if session[:tweet_items].nil?
  #       session[:tweet_items] = Array.new
  #     end
  #     @search_count = 15 #35がいいよー！
  #
  #     @uri = URI.parse("https://twitter.com/i/profiles/show/#{@user.nickname}/timeline/tweets?include_available_features=1&include_entities=1")
  #
  #     @twi_result = JSON.parse(Net::HTTP.get(@uri))
  #
  #     @twi_items = @twi_result["items_html"]
  #     @twi_ids = @twi_items.scan(/data-tweet-id="(.+)"/)
  #     @twi_ids.flatten!
  #
  #     @search_count.times do |i|
  #       @uri = URI.parse("https://twitter.com/i/profiles/show/#{@user.nickname}/timeline/tweets?include_available_features=1&include_entities=1&max_position=#{@twi_ids.last}&reset_error_state=false")
  #       @twi_result = JSON.parse(Net::HTTP.get(@uri))
  #       @twi_items = @twi_result["items_html"]
  #       twi_items_scaned = @twi_items.scan(/data-tweet-id="(.+)"/)
  #       if twi_items_scaned.empty?
  #         flash[:tweet_limit] = "一番古いツイートまで遡りました！"
  #         break
  #       end
  #       # if i * 1.5 >= @search_count
  #       session[:tweet_items].push(twi_items_scaned.sample)
  #       # end
  #       session[:tweet_items].flatten!
  #       puts session[:tweet_items].last
  #       @twi_ids.push(twi_items_scaned)
  #       @twi_ids.flatten!
  #       # session[:tweet_items].push(@twi_ids.sample)
  #
  #       # 実装時には死んでも消さないこと
  #       sleep(0.5)
  #     end
  #
  #   end
  # end

end
