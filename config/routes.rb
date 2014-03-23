Chawkolate::Application.routes.draw do

  root :to => 'home#index'

  #get "/auth/:provider/callback", to: 'user#create' 
  #get "/login", to: 'user#index' 
  #get "/logout", to: 'user#destroy' 

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  #resource :user

  get "user/index"
  get "user/create"
  get "user/destroy"

  namespace :api do
    namespace :v1 do
      resource :api_key, :only => :reset do
        put :reset
      end
      resources :nodes, :only=>[] do
        post :add_points
        put :clear
        put :increment
        put :decrement
        get :statistics
        get :last
        get :since
        get :range
      end
    end
  end

  get '/auth/google_oauth2/callback', to: 'home#auth'

  resources :event, :only => :listen do
    get :listen
  end

  resource  :search,    :only => :show
  resource  :dashboard, :only => :show
  resource  :profile,   :only => [:edit, :update]
  resources :stats,     :only => :index

end
