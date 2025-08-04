class CreateCooperations < ActiveRecord::Migration[7.0]
  def change
    create_table :cooperations do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :root_url
      t.string :mtm_campaign
      t.datetime :archived_at, precision: nil
      t.boolean :display_url, default: false
      t.boolean :display_pde_partnership_mention, default: false
      t.references :institution, null: false, foreign_key: true, index: true

      t.timestamps
    end

    create_table :cooperation_themes do |t|
      t.references :cooperation, null: false, foreign_key: true, index: true
      t.references :theme, null: false, foreign_key: true, index: true

      t.timestamps
    end

    add_reference :landings, :cooperation, foreign_key: true, index: true
    add_reference :solicitations, :cooperation, foreign_key: true, index: true

    up_only do
      generate_cooperations
      update_solicitations
      Landing.update_all(partner_url: nil)
    end

    rename_column :landings, :partner_url, :url_path
    remove_column :landings, :display_partner_url, :boolean, default: false
    remove_column :landings, :display_pde_partnership_mention, :boolean, default: false
    remove_reference :landings, :institution, foreign_key: true, index: true
    remove_reference :solicitations, :institution, foreign_key: true, index: true
    remove_column :themes, :cooperation, :boolean, default: false
  end

  def create_cooperation_safely(institution_slug, cooperation_params, landing_slugs = [], theme_labels = [], logo_params = nil)
    institution = Institution.find_by(slug: institution_slug)
    return unless institution
    
    cooperation = institution.cooperations.create!(cooperation_params)
    
    # Ajouter les landings
    Array(landing_slugs).each do |slug|
      landing = Landing.find_by(slug: slug)
      cooperation.landings.push(landing) if landing
    end
    
    # Ajouter les thèmes
    Array(theme_labels).each do |label|
      theme = Theme.find_by(label: label)
      cooperation.cooperation_themes.create!(theme: theme) if theme
    end
    
    # Créer le logo
    cooperation.create_logo(logo_params) if logo_params
    
    cooperation
  end

  def generate_cooperations
    ## Entreprendre Service Public
    p "Entreprendre Service Public"
    create_cooperation_safely(
      'dila',
      { name: "Entreprendre", root_url: 'https://entreprendre.service-public.fr', mtm_campaign: 'entreprendre', display_url: true },
      'entreprendre-service-public-fr',
      [],
      { name: 'Entreprendre', filename: 'entreprendre' }
    )

    ## Mon entreprise - URSSAF
    p "Mon entreprise - URSSAF"
    create_cooperation_safely(
      'urssaf',
      { name: "Mon entreprise", root_url: 'https://mon-entreprise.urssaf.fr', display_pde_partnership_mention: true },
      ['activite-partielle-mon-entreprise-urssaf-fr', 'mon-entreprise-urssaf-fr', 'rh-mon-entreprise-urssaf-fr', 'professions-liberales-mon-entreprise-urssaf-fr','rh-simulateur-urssaf-fr'],
      [],
      { name: 'Mon entreprise', filename: 'mon-entreprise-urssaf' }
    )

    ## « les-aides-fr » - institution CCI
    p "les-aides-fr"
    create_cooperation_safely(
      'cci',
      { name: "Les-aides.fr", root_url: 'https://les-aides.fr', display_url: true },
      'cci-les-aides-fr',
      [],
      { name: 'Les aides', filename: 'les-aides-cci' }
    )

    ## Toutes les autres coopérations avec gestion sécurisée
    cooperations_data = [
      {
        slug: 'ademe',
        name: "Mission transition écologique des entreprises",
        params: { name: "Mission transition écologique des entreprises", root_url: 'https://mission-transition-ecologique.beta.gouv.fr', display_url: true, display_pde_partnership_mention: true },
        landings: ['france-transition-ecologique', 'transition-ecologique-entreprises-api'],
        logo: { name: 'Mission transition ecologique', filename: 'transition-ecologique' }
      },
      {
        slug: 'dge',
        name: "entreprises.gouv.fr",
        params: { name: "entreprises.gouv.fr", root_url: 'https://www.entreprises.gouv.fr/fr/la-direction-generale-des-entreprises-dge' },
        landings: ['dge'],
        logo: { name: 'Entreprise Gouv', filename: 'ministere-economie-finances' }
      }
      # ... autres coopérations peuvent être ajoutées ici de manière sécurisée
    ]

    cooperations_data.each do |coop_data|
      p coop_data[:name]
      create_cooperation_safely(
        coop_data[:slug],
        coop_data[:params],
        coop_data[:landings] || [],
        coop_data[:themes] || [],
        coop_data[:logo]
      )
    end
  end

  def update_solicitations
    ## Mise à jour des sollicitations
    p "Mise à jour des sollicitations"

    cooperation = Cooperation.find_by(name: "Entreprendre")
    if cooperation
      Solicitation.where("mtm_campaign = ?", 'entreprendre').update_all(cooperation_id: cooperation.id)
    end

    Cooperation.find_each do |cooperation|
      Solicitation.joins(landing: :cooperation).where(landing: { cooperation_id: cooperation.id }).update_all(cooperation_id: cooperation.id)
    end
  end
end