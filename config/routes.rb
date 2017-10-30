Rails.application.routes.draw do
  devise_for :users

  resources :users do
  	resources :accounts 
  end

  get 'users/:id/logs/:lines' => "users#log", as: "log"
  get 'users/:id/approvalscreen' => "users#approvalscreen", as: "approvalscreen"
  get 'users/:id/approvalscreen_user' => "users#approvalscreen_user", as: "approvalscreen_user"
  get 'users/:user_id/accounts/:id/accountapprovalscreen' => "accounts#accountapprovalscreen", as: "accountapprovalscreen"
  get '/signout', to: 'devise/sessions#destroy', as: :signout

  resources :accounts do
      resources :trans
  end
  resources :users_admin, :controller => 'users'
  root to: "users#home"
  # root to: "accounts#index"
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  match "Download Statement" => "accounts_controller#download", via: :get
end
