# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  ActiveAdmin.routes(self)
  root to: 'home#index'
  get 'home/about'

  get 'profile' => 'users#show'
  patch 'profile' => 'users#update'

  resources :home, only: %i[] do
    collection do
      get :about
      get :contact
    end
  end

  resources :visits, only: %i[index show new create] do
    member do
      get 'company' => 'companies#show'
      get :edit_visitee
      patch :update_visitee
    end

    resources :diagnosis, only: %i[index new create show]
  end

  resources :companies, only: %i[], param: :siret do
    collection do
      post :search_by_siret
      post :search_by_siren
      post :search_by_name
    end
  end

  resources :mailto_logs, only: %i[create]

  namespace :api do
    resources :diagnoses, only: %i[show update]
    resources :contacts, only: %i[index show create update destroy]
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
