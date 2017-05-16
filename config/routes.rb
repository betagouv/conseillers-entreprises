# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users #, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'home#index'
  get 'home/about'

  resources :diagnosis, only: %i[index]

  resources :companies, only: %i[index show], param: :siret do
    post 'search', on: :collection
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
