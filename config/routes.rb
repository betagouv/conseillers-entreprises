Rails.application.routes.draw do
  # Pages
  controller :landings do
    root action: :index
    get 'entreprise/:slug', action: :show, as: :landing
    get 'aide/:slug', action: :show, as: :featured_landing
  end

  resource :solicitation, only: %i[create]

  controller :about do
    get :qui_sommes_nous
    get :cgu
    get :top_5
  end

  resource :stats, only: [:show] do
    collection do
      get :users
      get :activity
      get :cohorts

      get :tables
    end
  end

  # Application
  resources :diagnoses, only: %i[index new show], path: 'analyses' do
    collection do
      get :archives
      get :index_antenne
      get :archives_antenne
      post :create_diagnosis_without_siret
      get :find_cities
    end

    member do
      post :archive
      post :unarchive

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

  resources :needs, only: %i[index show], path: 'besoins' do
    collection do
      get :archives
      get :index_antenne
      get :archives_antenne
    end
    member do
      get :additional_experts
      post :add_match
    end
  end

  resources :matches, only: %i[update]
  resources :feedbacks, only: %i[create destroy]
  resources :experts, only: %i[edit update]

  resources :reminders, only: %i[index show], path: 'relances' do
    member do
      post :reminders_notes
    end
  end

  ## Redirection for compatibility
  get '/diagnoses', to: redirect('/analyses')

  # Devise
  devise_for :users,
             controllers: {
               registrations: 'users/registrations',
               invitations: 'users/invitations'
             },
             skip: [:registrations]
  devise_scope :user do
    get 'users/edit' => 'users/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'users/registrations#update', :as => 'user_registration'
  end

  get 'profile' => 'users#show'

  # ActiveAdmin
  ActiveAdmin.routes(self)

  # Impersonate
  mount UserImpersonate::Engine, at: '/impersonate', as: 'impersonate_engine'

  # LetterOpener
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end
