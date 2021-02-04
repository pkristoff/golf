Rails.application.routes.draw do
  root "welcome#index"

  get 'welcome/index'

  resources :courses do
    resources :addresses
    resources :tees do
      resources :holes
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
