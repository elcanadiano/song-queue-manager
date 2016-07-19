Rails.application.routes.draw do
  get 'notifications/new'

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

  resources :users do
    member do
      get 'bands'
    end
  end

  resources :account_activations, only:   [:edit]
  resources :password_resets,     only:   [:new, :create, :edit, :update]
  resources :notifications,       only:   [:index] do
    member do
      patch 'accept'
      patch 'decline'
    end
  end
  resources :events,              except: [:destroy] do
    member do
      patch 'toggle_open'
      get   'request'     => 'events#song_request'
    end
  end
  resources :song_requests, as: 'requests', only: [:create] do
    member do
      patch 'toggle_completed'
    end
  end

  resources :bands, except: [:index, :destroy] do
    member do
      get  'invite'
      post 'create_invite'
    end
  end
end
