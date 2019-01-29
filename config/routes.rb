Rails.application.routes.draw do

  get 'users/new'
  get 'users/home'
  root 'users#home'
  get  'users/help'
  get  'users/about'
  get  'users/contact'
  get 'session/new'
  get '/signup', to: 'users#new'
  post '/signup',  to: 'users#create'
  get  '/login',   to: 'sessions#new'
  post '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  get 'fetch_long_url', to: 'urls#fetch_long_url'
  post 'show_long_url', to: 'urls#show_long_url'
  get 'users/home'
  get 'urls/home'
  get 'urls/search'
  post 'urls/search_result'
  resources :users  
  resources :sessions
  resources :urls
  

  require 'sidekiq/web'
  mount Sidekiq::Web, :at => '/sidekiq'
  
end
