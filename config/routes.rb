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
  get 'courses/index'
  get 'courses/index/ta', to: 'courses#ta_index', as: 'ta_index'
  get  '/signup',  to: 'users#new'
  post '/signup',  to: 'users#create'
  get '/login', to: 'sessions#new'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  get '/create', to: 'assignments#new'
  root 'welcome#index'
  post 'grades', to: 'accept_grade#accept_grade'
  get '/submissions', to: 'submissions#index'
  resources :password_resets, only: [:new, :create, :edit, :update]
  get '/assignments/:id/grades', to: 'assignments#grades', as: 'assignment_grades'
  post '/assignments/:id/grades' , to: 'assignments#update_grade', as: 'assignment_grades_post'
  get 'courses/:id/addTA', to: 'courses#get_ta', as: 'add_ta'
  post 'courses/:id/addTA', to: 'courses#add_ta'
  get '/assignments/:id/grades/download', to: 'assignments#download', as: 'assigments_download'



  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
