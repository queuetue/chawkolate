Chawkolate::Application.routes.draw do

  root :to => 'home#index'

  resources :nodes do

  end

  resource :user

  devise_for :user, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end

  #get "/user/?", action: :index, controller: :user
  #get "user/index"
  #get "user/create"
  #get "user/destroy"

  namespace :api do
    namespace :v1 do
      resource :api_key, :only => :reset do
        put :reset
      end
      resources :nodes, :only=>[] do
        post :add_points
        put :clear_points
        put :increment
        put :decrement
        get :statistics
        get :last_points
        get :points_since
        get :points_range
      end
    end
  end

  get '/auth/google_oauth2/callback', to: 'home#auth'

  resources :event, :only => :listen do
    get :listen
  end

  resource  :search,    :only => :show
  #resource  :dashboard, :only => :show
  #resource  :profile,   :only => [:edit, :update]
  resources :stats,     :only => :index

end
