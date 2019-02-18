# frozen_string_literal: true

Rails.application.routes.draw do
  mount UserImpersonate::Engine => '/impersonate', as: 'impersonate_engine'
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root to: 'solicitations#index'

  get 'profile' => 'users#show'

  resource :stats, only: [:show] do
    collection do
      get :users
      get :activity
      get :cohorts

      get :tables
    end
  end

  resources :home, only: %i[] do
    collection do
      get :about
      get :cgu
      get :team
      get :index
    end
  end

  resource :solicitation, only: %i[create]

  resources :diagnoses, only: %i[index show destroy] do
    member do
      get :besoins, action: :step2
      post :besoins
      get :visite, action: :step3
      post :visite
      get :selection, action: :step4
      post :selection
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

  resources :feedbacks, only: %i[create destroy]

  get '/experts/diagnoses/:diagnosis', to: (redirect do |params, request|
    "/besoins/#{params[:diagnosis]}?#{request.params.slice(:access_token).to_query}"
  end)
end
