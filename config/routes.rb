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

  scope :annuaire, module: :annuaire do
    get '/', to: redirect('/annuaire/institutions')

    concern :importable do
      get :import, on: :collection
      post :import, action: :import_create, on: :collection
    end

    resources :institutions, param: :slug, only: %i[index show] do
      resources :subjects, path: 'domaines', only: :index
      resources :advisors, path: 'conseillers', only: :index, concerns: :importable
      resources :antennes, only: :index, concerns: :importable
    end
  end

  # Pages
  scope path: "(:iframe_prefix)", iframe_prefix: /e?/, defaults: { iframe_prefix: nil } do
    root controller: :landings, action: :index
    resources :landings, param: :slug, only: %i[show], path: 'aide-entreprises' do
      member do
        get 'demande(/:option_slug)', action: :new_solicitation, as: :new_solicitation
        # as the form to create solicitations is on the landings show page,
        # we’re using the same path the show landings and to view solicitations.
        post :create_solicitation, path: ''
      end
    end
  end

  resource :newsletters, only: %i[] do
    post :create
    get :new, path: 'abonnement'
  end

  resources :solicitations, only: %i[index show], path: 'sollicitations' do
    member do
      post :update_status
      post :update_badges
      post :prepare_diagnosis
    end
    collection do
      get :in_progress, path: 'relancees'
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
    get :comment_ca_marche
    get :cgu
    get :mentions_d_information
    get :mentions_legales
  end

  resource :stats, only: [:show] do
    collection do
      get :team
    end
  end

  controller :user_pages do
    get :tutoriels
  end

  controller :sitemap do
    get :sitemap
  end

  resource :company_satisfactions, only: %i[new create], path: 'satisfaction' do
    collection do
      get :thank_you, path: 'merci'
    end
  end

  # Application
  resources :diagnoses, only: %i[index new show create], path: 'analyses' do
    collection do
      get :processed, path: 'traitees'
      get :archives
      get :index_antenne
      get :archives_antenne
    end

    member do
      post :archive
      post :unarchive

      controller 'diagnoses/steps' do
        get :needs, path: 'besoins'
        patch :update_needs
        get :visit, path: 'visite'
        patch :update_visit
        get :matches, path: 'selection'
        patch :update_matches
      end
    end
  end

  resources :companies, only: %i[show], param: :siret do
    collection do
      get :search
    end
  end

  resources :needs, only: %i[index show], path: 'besoins' do
    collection do
      get :taking_care, path: 'pris_en_charges'
      get :archives
      get :archives_rejected, path: 'archives_rejetes'
      get :archives_failed, path: 'archives_en_echec'
      get :index_antenne
      get :taking_care_antenne, path: 'pris_en_charges_par_antenne'
      get :archives_antenne
      get :archives_antenne_rejected, path: 'archives_antenne_rejetes'
      get :archives_antenne_failed, path: 'archives_antenne_en_echec'
    end
    member do
      get :additional_experts
      post :add_match
      post :archive
      post :unarchive
    end
  end

  resources :matches, only: %i[update]
  resources :feedbacks, only: %i[create destroy]

  namespace :reminders, path: 'relances' do
    resources :experts, only: %i[index show], path: 'referents' do
      member do
        post :reminders_notes
        get :needs, path: 'besoins_en_attentes'
        get :needs_taking_care, path: 'besoins_pris_en_charges'
        get :needs_taking_care_by_others, path: 'besoins_pris_en_charges_par_dautres'
      end
    end
    resources :needs, path: 'besoins', only: %i[index] do
      collection do
        get :in_progress, path: 'en_cours'
        get :institutions, path: 'institutions_a_prevenir'
        get :abandoned, path: 'abandonnes'
      end
    end
  end

  resources :badges, only: %i[index create destroy]

  resources :partner_tools, only: %i[], path: 'outils-partenaires' do
    collection do
      get :inserts, path: 'encarts'
    end
  end

  get 'profile' => 'users#show'

  ## Redirection for compatibility
  get '/entreprise/:slug', to: redirect(path: '/aide-entreprises/%{slug}')
  get '/entreprise/:slug(*all)', to: redirect(path: '/aide-entreprises/%{slug}%{all}')
  get '/aide/:slug', to: redirect('/aide-entreprises/%{slug}')
  get '/aide/:slug(*all)', to: redirect(path: '/aide-entreprises/%{slug}%{all}')
  get '/profile', to: redirect('/mon_compte')
  get '/mes_competences', to: redirect('/mon_compte/referents')
  get '/diagnoses', to: redirect('/analyses')
  get '/qui_sommes_nous', to: redirect('/comment_ca_marche')
  get '/politique_de_confidentialite', to: redirect('/mentions_d_information')

  ## Handle 404 properly
  get '*unmatched_route', :to => 'shared#not_found'
end
