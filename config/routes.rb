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

  resources :diagnosis, only: %i[index] do
    get 'step-1' => 'diagnosis#step1', on: :collection

    member do
      get 'step-2' => 'diagnosis#step2'
      get 'step-3' => 'diagnosis#step3'
      get 'step-4' => 'diagnosis#step4'
    end
  end

  resources :visits, only: %i[show] do
    member do
      get 'company' => 'companies#show'
    end

    resources :diagnosis, only: %i[new create show] do
      get :index_ex, on: :collection
    end
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
    resources :facilities, only: %i[] do
      post :search_by_siret, on: :collection
    end

    resources :diagnoses, only: %i[show create update] do
      resources :diagnosed_needs, only: %i[create]
    end

    resources :visits, only: %i[] do
      resources :contacts, only: %i[index create]
    end

    resources :contacts, only: %i[show update destroy] do
      get :contact_button_expert, on: :collection
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
