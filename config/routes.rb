Rails.application.routes.draw do
  # resources :accounts
  devise_for :users
  
  
  resources :users do
  	resources :accounts
  end

  root to: "users#home"
  # root to: "accounts#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
