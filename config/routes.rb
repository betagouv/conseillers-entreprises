# frozen_string_literal: true

Rails.application.routes.draw do
  mount UserImpersonate::Engine => '/impersonate', as: 'impersonate_engine'
  ActiveAdmin.routes(self)
  devise_for :users, controllers: { registrations: 'users/registrations' }

  root to: 'home#index'

  get 'video' => 'home#tutorial_video'
  get 'profile' => 'users#show'

  resources :home, only: %i[] do
    collection do
      get :about
      get :cgu
      get :contact
    end
  end

  resources :diagnoses, only: %i[index destroy] do
    collection do
      get 'print'
    end

    member do
      get 'step-2' => 'diagnoses#step2'
      get 'step-3' => 'diagnoses#step3'
      get 'step-4' => 'diagnoses#step4'
      get 'step-5' => 'diagnoses#step5'
      post :notify
    end
  end

  resources :companies, only: %i[show], param: :siret do
    collection do
      get :search
      post :create_diagnosis_from_siret
    end
  end

  resources :experts, only: %i[] do
    collection do
      get 'diagnoses/:diagnosis_id' => 'experts#diagnosis', as: :diagnosis
      patch :update_status
    end
  end

  resources :territory_users, only: %i[] do
    collection do
      get :diagnoses
      get 'diagnoses/:diagnosis_id' => 'territory_users#diagnosis', as: :diagnosis
      patch :update_status
    end
  end

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

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
