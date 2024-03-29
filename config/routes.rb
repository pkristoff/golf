Rails.application.routes.draw do
  root "welcome#index"

  get 'welcome/index'
  post 'welcome/clear_db'
  get 'welcome/filein_db'
  post 'welcome/upload'

  resources :accounts do
    collection do
      get 'accounts_index'
    end
  end

  resources :courses do
    collection do
      get 'rounds_index'
    end
    resources :addresses
    resources :tees do
      collection do
        get 'rounds_tees'
      end
      resources :performances
      resources :holes
      resources :rounds do
        resources :scores
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
