class CreateLandingSubjects < ActiveRecord::Migration[6.1]
  def change
    create_table :landing_themes do |t|
      t.references :landing, null: true, foreign_key: true
      t.string :title
      t.string :slug
      t.text :description
      t.integer :position
      t.string :meta_title
      t.string :meta_description
      t.string :logos
      t.timestamps null: false
    end

    create_table :landing_subjects do |t|
      t.references :landing_theme, null: false, foreign_key: true
      t.references :subject, null: false, foreign_key: true
      t.string :title
      t.string :slug
      t.text :description
      t.integer :position
      t.string :meta_title
      t.string :meta_description
      t.string :form_title
      t.text :form_description
      t.text :description_explanation
      t.boolean :requires_siret, default: false, null: false
      t.boolean :requires_requested_help_amount, default: false, null: false
      t.boolean :requires_location, default: false, null: false

      t.timestamps null: false
    end
    add_column :landings, :single_page, :boolean, default: false

    # Utilisé uniquement sur "relance"
    # - emphasis
    # - main_logo

    # A faire passer en iframe : 'brexit', 'relance-hautsdefrance', 'france-transition-ecologique'
    up_only do
      def defaults_landing_theme_attributes(landing)
        {
          landing_id: landing.id,
          title: landing.home_title,
          slug: landing.home_title.parameterize,
          description: landing.home_description || landing.meta_description,
          position: landing.home_sort_order,
          meta_title: landing.meta_title,
          meta_description: landing.meta_description,
        }
      end

      def defaults_landing_subject_attributes(landing_theme, landing_topic)
        p "defaults_landing_subject_attributes =========="
        p landing_topic
        landing_option = LandingOption.find_by(slug: landing_topic.landing_option_slug)
        subject = Subject.find_by(slug: landing_option.preselected_subject_slug)
        p landing_option
        p subject
        {
          landing_theme_id: landing_theme.id,
          subject_id: subject.id,
          title: landing_topic.title,
          slug: landing_topic.title.parameterize,
          description: landing_topic.description,
          position: landing_topic.landing_sort_order,
          meta_title: landing_option.meta_title,
          form_title: landing_option.form_title,
          form_description: landing_option.form_description,
          description_explanation: landing_option.description_explanation,
          requires_siret: landing_option.requires_siret,
          requires_requested_help_amount: landing_option.requires_requested_help_amount,
          requires_location: landing_option.requires_location
        }
      end

      ## Home Landing
      home_landing = Landing.create(
        title: 'home',
        slug: 'home'
      )

      # Themes de la page d'accueil
      Landing.where.not(home_sort_order: nil).each do |landing|
        landing_theme_attributes = defaults_landing_theme_attributes(landing).merge(
          landing_id: home_landing.id
        )
        landing_theme = LandingTheme.create(landing_theme_attributes)
        landing.landing_topics.order(:landing_sort_order).each do |lt|
          ls_attributes = defaults_landing_subject_attributes(landing_theme, lt)
          LandingSubject.create(ls_attributes)
        end
      end

      # Landing avec des group_name
      Landing.where(slug: ['relance', 'brexit', 'relance-hautsdefrance']).each do |landing|
        landing.update(single_page: true)
        # Create themes for each group_name
        landing.landing_topics.order(:landing_sort_order).pluck(:group_name).compact.each_with_index do |group_name, idx|
          landing_theme_attributes = defaults_landing_theme_attributes(landing).merge(
            title: group_name,
            slug: group_name.parameterize,
            position: idx
          )
          LandingTheme.create(landing_theme_attributes)
        end
        landing.landing_topics.order(:landing_sort_order).each do |lt|
          landing_theme = LandingTheme.find_by(title: lt.group_name)
          ls_attributes = defaults_landing_subject_attributes(landing_theme, lt)
          LandingSubject.create(ls_attributes)
        end
      end

      ## Landing "contactez-nous"
      Landing.where(slug: ['contactez-nous']).each do |landing|
        landing.update(single_page: true)
        landing_theme_attributes = defaults_landing_theme_attributes(landing).merge(
          title: 'Échanger avec un conseiller pour :',
          position: 1
        )
        landing_theme = LandingTheme.create(landing_theme_attributes)
        landing.landing_topics.order(:landing_sort_order).each do |lt|
          ls_attributes = defaults_landing_subject_attributes(landing_theme, lt)
          LandingSubject.create(ls_attributes)
        end
      end
    end
  end
end

# LandingOption.find_by(slug: "energie").update(preselected_subject_slug: "environnement_transition_ecologique_rse_gestion_de_l_energie")
# LandingOption.find_by(slug: "dechets").update(preselected_subject_slug: "environnement_transition_ecologique_rse_traitement_et_valorisation_des_dechets")
# LandingOption.find_by(slug: "eau").update(preselected_subject_slug: "environnement_transition_ecologique_rse_gestion_de_l_eau")
# LandingOption.find_by(slug: "bilan_RSE").update(preselected_subject_slug: "environnement_transition_ecologique_rse_bilan_et_strategie_rse")
# LandingOption.find_by(slug: "transport_mobilite").update(preselected_subject_slug: "environnement_transition_ecologique_rse_transport_et_mobilite")
# LandingOption.find_by(slug: "demarche_ecologie").update(preselected_subject_slug: "environnement_transition_ecologique_rse_demarche_generale_de_transition_ecologique_strategie_eco_conception_labels")

# LandingTopic.where(title: "").destroy_all

# LandingOption.find_by(slug: 'obligations_sante_securite').update(preselected_subject_slug: "sante_et_securite_au_travail_repondre_a_mes_obligations_en_matiere_de_sante_et_de_securite")
# LandingOption.find_by(slug: 'former_risques_professionnels').update(preselected_subject_slug: "sante_et_securite_au_travail_former_ses_salaries_a_la_prevention_des_risques_professionnels")
# LandingOption.find_by(slug: 'qualite_de_vie_au_travail').update(preselected_subject_slug: "sante_et_securite_au_travail_ameliorer_la_qualite_de_vie_au_travail_management_teletravail")
