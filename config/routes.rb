Rails.application.routes.draw do
  resources :submissions
  resources :assignments
  resources :t_as_classes
  resources :teaches_classes
  resources :takes_classes
  resources :courses
  resources :users

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
