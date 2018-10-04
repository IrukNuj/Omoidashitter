Rails.application.routes.draw do
  get 'home/index'
  get 'home/login'
  get 'home/tweet'
  get 'home/tweet_search_repeat'
  get 'sessions/create'
  get 'sessions/destroy'
  root 'home#index'
  get '/auth/twitter/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  get '/login', to: 'home#login'
end