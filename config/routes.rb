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

  resources :visits, only: %i[index new create] do
    member do
      get :edit_visitee
      patch :update_visitee
    end

    resources :diagnosis, only: %i[index] do
      collection do
        get 'question/:id' => 'diagnosis#question', as: :question
      end
    end

    resources :companies, only: %i[index show], param: :siret do
      collection do
        post 'search'
        post 'search_with_name'
      end
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
