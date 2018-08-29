# frozen_string_literal: true

Rails.application.routes.draw do
  mount UserImpersonate::Engine => '/impersonate', as: 'impersonate_engine'
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root to: 'home#index'

  get 'video' => 'home#tutorial_video'
  get 'profile' => 'users#show'

  resources :stats, only: [:index] do
    collection do
      get :users
      get :activity
    end
  end

  resources :home, only: %i[] do
    collection do
      get :about
      get :cgu
      get :contact
    end
  end

  resources :diagnoses, only: %i[index show destroy] do
    member do
      get :besoins, action: :step2
      post :besoins
      get :visite, action: :step3
      post :visite
      get :selection, action: :step4
      post :selection
      get :resume, action: :step5
    end
  end

  resources :companies, only: %i[show], param: :siret do
    collection do
      get :search
      post :create_diagnosis_from_siret
    end
  end

  resources :besoins, controller: 'needs', only: %i[index show]

  resources :matches, only: %i[update]

  get '/experts/diagnoses/:diagnosis', to: (redirect do |params, request|
    "/besoins/#{params[:diagnosis]}?#{request.params.slice(:access_token).to_query}"
  end)

  namespace :api do
    resources :diagnoses, only: %i[show create update] do
      resources :diagnosed_needs, only: %i[index] do
        post :bulk, on: :collection
      end
    end

    resources :visits, only: %i[show update] do
      resources :contacts, only: %i[index create]
    end

    resources :contacts, only: %i[show update]

    resources :errors, only: %i[create]
  end
end
