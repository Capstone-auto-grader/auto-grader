Rails.application.routes.draw do
  resources :assignments do
    resources :submissions
  end
  # resources :submissions
  resources :courses
  resources :users
  get 'sessions/new'
  get 'users/new'
  get 'welcome/index'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  root 'welcome#index'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
