Rails.application.routes.draw do

  root to: 'home#index'

  resources :companies, only: [:index, :show]


  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
