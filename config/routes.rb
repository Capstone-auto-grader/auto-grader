Rails.application.routes.draw do
  resources :containers
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  resources :assignments do
    resources :submissions
    collection do
      post :download_latte_csv
      post :download_tom_csv
    end
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
  post 'batch', to: 'accept_grade#accept_batch'
  post '/moss', to: 'accept_grade#accept_moss'
  get '/submissions', to: 'submissions#index'
  resources :password_resets, only: [:new, :create, :edit, :update]
  get '/assignments/:id/grades', to: 'assignments#grades', as: 'assignment_grades'
  post '/assignments/:id/grades' , to: 'assignments#update_grade', as: 'assignment_grades_post'
  patch '/assignments/:id/upload_submissions', to: 'assignments#upload_submissions', as: 'upload_submissions'
  patch '/assignments/:id/submissions/:sub_id/upload_individual_submission', to: 'assignments#upload_individual_submission', as: 'upload_individual_submission'
  get 'courses/:id/addTA', to: 'courses#get_ta', as: 'add_ta'
  post 'courses/:id/addTA', to: 'courses#add_ta'
  get 'courses/:id/addStudent', to: 'courses#get_student', as: 'add_student'
  post 'courses/:id/addStudent', to: 'courses#add_student'
  get 'courses/:id/deleteTA', to: 'courses#delete_ta', as: 'delete_ta'
  get 'courses/:id/deleteStudent', to: 'courses#delete_student', as: 'delete_student'
  get '/assignments/:id/grades/download', to: 'assignments#download', as: 'assigments_download'
  get '/assignments/:id/grades/download-partition', to: 'assignments#download_partition', as: 'download_partition'
  get '/assignments/:id/grades/partitions', to: 'assignments#show_partition', as: 'show_partition'
  get '/assignments/:id/grades/invalid', to: 'assignments#download_invalid', as: 'download_invalid'
  post '/conflict_add', to: 'courses#conflict_add', as: 'conflict_add'
  post '/conflict_remove', to: 'courses#conflict_remove', as: 'conflict_remove'


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
