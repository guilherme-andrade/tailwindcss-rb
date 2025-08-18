Rails.application.routes.draw do
  mount ActionCable.server => "/cable"
  
  resources :pages, only: [:index, :show]
  root "pages#index"
end