Rails.application.routes.draw do
  # ActiveAdmin
  ActiveAdmin.routes(self)

  # Impersonate
  mount UserImpersonate::Engine, at: '/impersonate', as: 'impersonate_engine'

  # LetterOpener
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?

  # Devise
  devise_for :users,
             path: 'mon_compte',
             controllers: {
               registrations: 'users/registrations',
               invitations: 'users/invitations'
             },
             skip: [:registrations]

  devise_scope :user do
    resource :'user', only: %i[show update], path: 'mon_compte', controller: 'users/registrations' do
      get :edit, path: 'informations'
      get :password, path: 'mot_de_passe'
      get :antenne
    end
  end

  scope 'mon_compte', as: '' do
    resources :experts, only: %i[index edit update], path: 'referents' do
      member do
        get :subjects, path: 'domaines'
      end
    end
  end

  # Pages
  controller :landings do
    root action: :index
    get 'aide-entreprises/:slug', action: :show, as: :landing
    post :create_solicitation
  end

  resources :solicitations, only: %i[index show], path: 'sollicitations' do
    member do
      post :update_status
    end
    collection do
      get :processed, path: 'traitees'
      get :canceled, path: 'annulees'
    end
    collection do # Nice pagination paths instead of the ?page= parameter (for kaminari)
      get 'page/:page', action: :index
      get 'traitees/page/:page', action: :processed
      get 'annulees/page/:page', action: :canceled
    end
  end

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

      controller 'diagnoses/steps' do
        get :besoins
        post :besoins
        get :visite
        post :visite
        get :selection
        post :selection
      end
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

  resources :reminders, only: %i[index show], path: 'relances' do
    member do
      post :reminders_notes
    end
  end

  controller :user_pages do
    get :tutoriels
  end

  get 'profile' => 'users#show'

  resources :external_solicitations, only: %i[new create]

  ## Redirection for compatibility
  get '/entreprise/:slug', to: redirect(path: '/aide-entreprises/%{slug}')
  get '/entreprise/:slug(*all)', to: redirect(path: '/aide-entreprises/%{slug}%{all}')
  get '/aide/:slug', to: redirect('/aide-entreprises/%{slug}')
  get '/aide/:slug(*all)', to: redirect(path: '/aide-entreprises/%{slug}%{all}')
  get '/profile', to: redirect('/mon_compte')
  get '/mes_competences', to: redirect('/mon_compte/referents')
  get '/diagnoses', to: redirect('/analyses')

  ## Handle 404 properly
  get '*unmatched_route', :to => 'shared#not_found'
end
