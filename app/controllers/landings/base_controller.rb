class Landings::BaseController < PagesController
  include IframePrefix

  before_action :retrieve_landing, except: [:home]

  private

  def retrieve_landing
    landing_slug = params.permit(:landing_slug)[:landing_slug]&.to_sym
    @landing = Rails.cache.fetch("landing-#{landing_slug}", expires_in: 1.minute) do
      Landing.find_by(slug: landing_slug)
    end

    # temporary redirections
    if @landing.nil?
      landing_theme = LandingTheme.find_by(slug: params[:landing_slug])
    end
    home_landings = %w[contactes-nous relance]
    if @landing.nil? && landing_theme.present?
      slug = find_subject_slug[params[:slug]]
      redirect_to landing_subject_path('home', slug), status: :moved_permanently
    elsif home_landings.include?(@landing.slug) && params[:slug].present? && find_subject_slug[params[:slug]].present?
      slug = find_subject_slug[params[:slug]]
      redirect_to landing_subject_path(@landing.slug, slug), status: :moved_permanently
    elsif !@landing.slug == 'home' && home_landings.exclude?(@landing.slug)
      redirect_to root_path, status: :moved_permanently
    end
  end

  def find_subject_slug
    {
      'recruter' => 'recruter-un-ou-plusieurs-salaries',
      'former' => 'mettre-en-place-un-projet-de-formation',
      'organisation_du_travail' => 'ameliorer-l-organisation-du-travail-et-la-gestion-des-carrieres',
      'dialogue_social' => 'ameliorer-le-dialogue-social-en-entreprise',
      'financer_projet' => 'financer-vos-projets-d-investissement',
      'reduction_impots' => 'solliciter-des-avantages-fiscaux-et-des-reductions-d-impots',
      'projet_innovation' => 'realiser-un-projet-d-innovation',
      'projet_immobilier' => 'realiser-un-projet-foncier-ou-immobilier',
      'diagnostic' => 'faire-un-diagnostic-de-votre-situation-economique-et-financiere',
      'tresorerie' => 'resoudre-un-probleme-de-tresorerie-faire-face-a-vos-charges',
      'litige' => 'resoudre-a-l-amiable-un-differend-avec-un-partenaire-public-ou-prive',
      'droit_du_travail' => 'obtenir-un-renseignement-en-droit-du-travail',
      'activite_partielle' => 's-informer-sur-l-activite-partielle-en-cas-de-baisse-d-activite',
      'strategie' => 'faire-un-point-sur-votre-strategie-adapter-votre-activite-au-nouveau-contexte',
      'nouvelle_offre_produit_service' => 'developper-une-nouvelle-offre-de-produits-ou-de-services',
      'clients' => 'trouver-de-nouveaux-clients-elargir-votre-reseau-professionnel',
      'international' => 'developper-un-projet-a-l-international',
      'vendre_sur_internet' => 'vendre-sur-internet',
      'visibilite_sur_internet' => 'ameliorer-votre-visibilite-sur-internet',
      'proteger_vos_donnees' => 'proteger-vos-donnees',
      'demarche_ecologie' => 'demarche-generale-de-transition-ecologique-strategie-eco-conception-labels',
      'energie' => 'gestion-de-l-energie',
      'dechets' => 'traitement-et-valorisation-des-dechets',
      'eau' => 'gestion-de-l-eau',
      'transport_mobilite' => 'transport-et-mobilite',
      'bilan_RSE' => 'bilan-et-strategie-rse',
      'obligations_sante_securite' => 'repondre-a-vos-obligations-en-matiere-de-sante-et-de-securite',
      'former_risques_professionnels' => 'former-vos-salaries-aux-risques-professionnels',
      'qualite_de_vie_au_travail' => 'ameliorer-la-qualite-de-vie-au-travail-management-teletravail',
      'vendre_entreprise' => 'vendre-votre-entreprise',
      'reprendre_entreprise' => 'reprendre-une-entreprise',
      'formalites_entreprise' => 'modifier-ou-completer-vos-formalites-d-entreprise-etre-conseille-sur-le-choix-d-un-nouveau-statut',
      'declaration_organisme_formation' => 'declarer-votre-entreprise-comme-organisme-de-formation',
      'agrement_esus' => 's-informer-sur-l-agrement-entreprise-solidaire-d-utilite-sociale-esus-et-ses-avantages',
      'problematique_reglementaire' => 'resoudre-une-problematique-reglementaire',
      'autre_demande' => 'faire-une-autre-demande'
    }
  end

  def save_form_info
    form_info = session[:solicitation_form_info] || {}
    info_params = show_params.slice(*Solicitation::FORM_INFO_KEYS)
    form_info.merge!(info_params)
    session[:solicitation_form_info] = form_info if form_info.present?
  end

  def show_params
    params.permit(:slug, *Solicitation::FORM_INFO_KEYS)
  end
end
