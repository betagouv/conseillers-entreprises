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
    resource :user, only: %i[show update], path: 'mon_compte', controller: 'users/registrations' do
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
      resources :users, path: 'conseillers', only: :index, concerns: :importable
      resources :antennes, only: :index, concerns: :importable do
        resources :users, path: 'conseillers', only: :index
      end
    end
  end

  # Pages
  # root controller: :landings, action: :index
  root controller: "landings/landings", action: :home
  resources :landings, param: :slug, controller: "landings/landings", only: [:show], path: 'aide-entreprise' do
    resources :landing_themes, param: :slug, controller: "landings/landing_themes", path: 'theme', as: 'theme', only: %i[show]
    resources :landing_subjects, param: :slug, controller: "landings/landing_subjects", path: 'demande', as: 'subject', only: %i[show] do
      post :create_solicitation, on: :member
    end
  end

  resource :newsletters, only: %i[] do
    post :create
    get :new, path: 'abonnement', as: :new
    get :index, to: redirect('/newsletters/abonnement')
  end

  resources :solicitations, only: %i[index show], path: 'sollicitations' do
    member do
      post :update_status
      post :update_badges
      post :prepare_diagnosis
    end
    collection do
      get :reminded, path: 'relancees'
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
    get :accessibilite
  end

  scope :stats, module: :stats do
    resources :public, only: :index, path: '/'
    resources :team, only: :index, path: 'equipe' do
      collection do
        get :quality, path: 'suivi-qualite'
        get :matches, path: 'mises-en-relation'
        get :deployment, path: 'deploiement'
      end
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

  resources :companies, only: %i[show], param: :siret, path: 'entreprises' do
    member do
      get :needs, path: 'besoins'
    end
    collection do
      get :search
    end
  end

  resources :needs, only: %i[index show], path: 'besoins' do
    collection do
      # TODO: We could use a single route like this:
      # /besoins(/antenne)/:collection_name
      # See needs_controller.rb and #1278
      get :quo, path: 'boite_de_reception'
      get :taking_care, path: 'prises_en_charge'
      get :done, path: 'cloturees'
      get :not_for_me, path: 'refusees'
      get :expired, path: 'expirees'

      get :antenne_quo, path: 'antenne/boite_de_reception'
      get :antenne_taking_care, path: 'antenne/prises_en_charge'
      get :antenne_done, path: 'antenne/cloturees'
      get :antenne_not_for_me, path: 'antenne/refusees'
      get :antenne_expired, path: 'antenne/expirees'
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

  resources :reminders_actions, only: [] do
    member do
      post :poke
      post :recall
      post :warn
      post :archive
    end
  end

  namespace :reminders, path: 'relances' do
    get '/', to: redirect('/relances/besoins')

    resources :experts, only: %i[index], path: 'referents' do
      member do
        post :reminders_notes
        get :quo, path: 'boite_de_reception'
        get :taking_care, path: 'prises_en_charge'
        get :done, path: 'cloturees'
        get :not_for_me, path: 'refusees'
        get :expired, path: 'expirees'
      end
    end
    resources :needs, path: 'besoins', only: %i[index] do
      collection do
        get :poke, path: 'a-relancer'
        get :recall, path: 'a-rappeler'
        get :warn, path: 'institution-a-prevenir'
        get :archive, path: 'abandonnes'
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
  get '/rech-etablissement', to: 'utilities#search_etablissement'

  ## Redirection for compatibility
  ### Landings - Accueil
  ["recrutement-formation", "financement-projets", "entreprise-en-difficulte", "droit-du-travail", "developpement-commercial", "internet-web", "environnement-transition-ecologique", "sante-securite-travail", "cession-reprise"].each do |theme|
    get "/aide-entreprises/#{theme}", to: redirect(path: "aide-entreprise/accueil/theme/#{theme}")
    get "/aide-entreprises/#{theme}/demande/:option_slug", to: redirect { |path_params, req| "/aide-entreprise/accueil/demande/#{path_params[:option_slug].dasherize.parameterize}" }
  end
  ### Landings - autres locales
  ["contactez-nous", "relance"].each do |landing|
    get "/aide-entreprises/#{landing}", to: redirect(path: "aide-entreprise/#{landing}")
    get "/aide-entreprises/#{landing}/demande/:option_slug", to: redirect { |path_params, req| "/aide-entreprise/#{landing}/demande/#{path_params[:option_slug].dasherize.parameterize}" }
  end
  ### Landings - Iframe
  ["relance-hautsdefrance", "brexit", "france-transition-ecologique"].each do |landing|
    get "/e/aide-entreprises/#{landing}", to: redirect(path: "aide-entreprise/#{landing}")
  end
  get '/e', to: redirect { |path_params, req|
    query_params = Rack::Utils.parse_query(req.query_string)
    hash = {
      'conseil_regional_hauts_de_france' => 'entreprises-haut-de-france',
      'collectivite_de_martinique' => 'zetwal'
    }
    "/aide-entreprise/#{hash[query_params['institution']]}"
  }

  # Others
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
