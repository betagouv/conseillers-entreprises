module ApiSpecHelper
  def authentication_headers(organization = Organization.first)
    token = find_token(organization)
    @authentication_headers ||= { 'Authorization' => "Bearer token=#{token}" }
  end

  def find_token(institution = Institution.first)
    token = SecureRandom.hex(32)
    if institution.api_key.present?
      institution.api_key.update(token: token)
    else
      institution.create_api_key(token: token)
    end
    token
  end

  # Base data -----------------------------

  def create_base_landing(institution)
    create(:landing, :api, institution: institution, title: 'Page d’atterrissage 01', slug: 'page-atterrissage-01')
  end

  ## Recrutement formation
  def create_rh_theme(landings)
    create(:landing_theme, landings: landings,
      title: 'Recruter ou former vos salariés, améliorer l’organisation du travail', slug: 'recrutement-formation',
      description: 'S’informer sur les aides à l’embauche, trouver des candidats, recruter un travailleur handicapé, identifier la bonne formation, être accompagné sur la GPEC, gérer les départs en retraite.')
  end

  def create_recrutement_subject(landing_theme)
    recrutement_subject = create(:landing_subject, landing_theme: landing_theme,
      title: 'Recruter un ou plusieurs salariés', slug: 'recruter',
      description: "<ul><li>S’informer sur les aides à l'embauche des jeunes, à l'apprentissage</li><li>S'informer sur les emplois francs en quartiers prioritaires, le contrat de professionnalisation, le VTE Vert sur les métiers de la transition écologique</li><li>Trouver des candidats</li></ul>",
      description_explanation: "<ul><li>le type de poste</li><li>si l'offre est déjà connue de Pôle emploi</li><li>si vous envisagez de recruter une personne en situation de handicap</li></ul>",
      requires_siret: true,
      requires_requested_help_amount: false)
    cci = create(:institution, name: "Chambre de Commerce et d'Industrie (CCI)", logo: Logo.create(filename: 'cci', name: 'Cci'))
    cci.institutions_subjects.create(subject: recrutement_subject.subject)
    recrutement_subject
  end

  def create_formation_subject(landing_theme)
    create(:landing_subject, landing_theme: landing_theme,
      title: 'Mettre en place un projet de formation', slug: 'former',
      description: "<ul><li>Choisir la bonne formation</li><li>Trouver votre OPCO, financer la formation</li><li>Mettre en place un plan de formation entreprise</li><li>Se former en tant que chef d'entreprise</li><li>Former vos salariés en activité partielle grâce au FNE formation</li></ul>",
      description_explanation: "<ul><li>votre activité</li><li>combien de salariés vous souhaitez former</li><li>sur quelles thématiques</li><li>dans quel but</li></ul>",
      requires_siret: true,
      requires_requested_help_amount: false)
  end

  def create_cadre_question(pde_subject)
    create :additional_subject_question, subject: pde_subject, key: 'recrutement_poste_cadre', position: 1
  end

  def create_apprentissage_question(pde_subject)
    create :additional_subject_question, subject: pde_subject, key: 'recrutement_en_apprentissage', position: 2
  end

  ## Environnement
  def create_ecolo_theme(landings)
    create(:landing_theme, landings: landings,
      title: 'Environnement, transition écologique & RSE', slug: 'environnement-transition-ecologique',
      description: 'Optimiser vos consommations d’énergie, valoriser vos déchets par la revente de matière, éco-concevoir un produit, mettre en place une démarche RSE, un plan de déplacement entreprise (PDE).')
  end

  def create_dechet_subject(landing_theme)
    create(:landing_subject, landing_theme: landing_theme,
      title: 'Traitement et valorisation des déchets', slug: 'dechets',
      description: "<ul><li>Optimiser votre tri sélectif en entreprise</li><li>Réduire vos déchets</li><li>Valoriser la revente de matières, trouver de nouveaux débouchés</li></ul>",
      description_explanation: "<ul><li>quelle est concrètement votre activité</li><li>ce que votre projet apporte à votre entreprise</li><li>quel accompagnement vous souhaitez (réflexion stratégique, appui technique ou appui à la mise en oeuvre)</li></ul>",
      requires_siret: true,
      requires_requested_help_amount: false)
  end

  def create_eau_subject(landing_theme)
    create(:landing_subject, landing_theme: landing_theme,
      title: 'Gestion de l’eau', slug: 'eau',
      description: "<ul><li>Réduire vos consommations d’eau</li><li>Dimensionner la récupération d’eau pluviale</li><li>Maintenir de la biodiversité sur votre territoire</li></ul>",
      description_explanation: "<ul><li>quelle est concrètement votre activité</li><li>si vous utilisez de l’eau dans votre process de fabrication</li><li>ce que votre projet apporte à votre entreprise</li><li>quel accompagnement vous souhaitez (réflexion stratégique, appui technique ou appui à la mise en oeuvre)</li></ul>",
      requires_siret: true,
      requires_requested_help_amount: false)
  end

  ## Santé
  def create_sante_theme(landings)
    create(:landing_theme, landings: landings,
      title: 'Améliorer la santé et la sécurité au travail', slug: 'sante-securite-travail',
      description: 'Réviser votre document unique d’évaluation des risques professionnels, former vos salariés à la prévention des risques professionnels (DUERP), connaître les règles d’hygiène, améliorer la qualité de vie au travail pour être plus performant.')
  end

  def create_obligations_sante_subject(landing_theme)
    create(:landing_subject, landing_theme: landing_theme,
      title: 'Répondre à vos obligations en matière de santé et de sécurité', slug: 'obligations-sante-securite',
      description: "<ul><li>Rédiger ou réviser votre document unique d'évaluation des risques professionnels (DUERP)</li><li>Faire une étude de poste</li><li><span style=\"background-color: rgb(255, 255, 255);\">Réduire la pénibilité au travail, m</span>onter un dossier de subvention Carsat</li><li>Connaître les règles d'hygiène applicables à votre activité</li></ul>",
      description_explanation: "<ul><li>votre activité</li><li>si vous avez un document unique</li><li>ce qui a déjà été mis en place</li></ul>",
      requires_siret: true,
      requires_requested_help_amount: false)
  end
end
