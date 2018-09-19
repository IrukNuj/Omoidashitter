Rails.application.routes.draw do
  root 'home#index'
  get '/auth/twitter/callback', to: 'sessions#create'
  get '/logout', to: 'sessions#destroy'
  get '/login', to: 'home#login'
end
