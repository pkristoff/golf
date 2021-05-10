Rails.application.routes.draw do
  root "welcome#index"

  get 'welcome/index'
  get 'welcome/clear_db'
  get 'welcome/filein_db'
  post 'welcome/upload'

  resources :courses do
    collection do
      get 'rounds_index'
    end
    resources :addresses
    resources :tees do
      collection do
        get 'rounds_tees'
      end
      resources :holes
      resources :rounds do
        resources :scores
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
