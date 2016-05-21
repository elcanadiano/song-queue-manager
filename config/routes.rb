Rails.application.routes.draw do
  get 'events/new'

  get 'models/new'

  get 'password_resets/new'

  get 'password_resets/edit'

  get 'sessions/new'

  get 'users/new'

  root                'static_pages#home'
  get    'help'    => 'static_pages#help'
  get    'about'   => 'static_pages#about'
  get    'contact' => 'static_pages#contact'
  get    'signup'  => 'users#new'
  get    'login'   => 'sessions#new'
  post   'login'   => 'sessions#create'
  delete 'logout'  => 'sessions#destroy'

  resources :microposts
  resources :users do
    member do
      get 'bands'
    end
  end

  resources :account_activations, only:   [:edit]
  resources :password_resets,     only:   [:new, :create, :edit, :update]
  resources :events,              except: [:show, :destroy] do
    member do
      patch 'toggle_open'
    end
  end

  resources :bands, only: [:new, :create]
end
