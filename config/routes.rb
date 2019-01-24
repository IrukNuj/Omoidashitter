Rails.application.routes.draw do
  get 'home/index'
  get 'home/login', to: 'new'
  get 'home/tweet', to: 'home#show'
  get 'home/tweet_search_repeat'
  get 'sessions/create'
  get 'sessions/destroy'
  root 'home#index'
  get '/auth/twitter/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  get '/login', to: 'home#login'
end