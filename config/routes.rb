# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }
  ActiveAdmin.routes(self)
  root to: 'home#index'
  get 'home/about'
  get 'profile' => 'users#show'

  resources :diagnosis, only: %i[index] do
    collection do
      get 'answer/:id' => 'diagnosis#answer', as: :answer
    end
  end

  resources :companies, only: %i[index show], param: :siret do
    post 'search', on: :collection
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
