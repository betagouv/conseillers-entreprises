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
    collection do
      get 'answer/:id' => 'diagnosis#answer', as: :answer
    end
  end

  resources :visits, only: %i[new create] do
    get :prepare_email, on: :member
  end

  resources :companies, only: %i[index show], param: :siret do
    post 'search', on: :collection
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
