Rails.application.routes.draw do
  devise_for :users

  resources :users do
  	resources :accounts 
  end

  resources :accounts do
      resources :trans
  end
  resources :users_admin, :controller => 'users'
  root to: "users#home"
  # root to: "accounts#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
