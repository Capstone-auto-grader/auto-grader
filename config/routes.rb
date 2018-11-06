Rails.application.routes.draw do
  root 'users#index'
  resources :assignments
  resources :submissions
  resources :t_as_classes
  resources :teaches_classes
  resources :takes_classes
  resources :courses
  resources :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
