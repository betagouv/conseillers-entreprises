class AddInstitutionToLogos < ActiveRecord::Migration[6.1]
  def up
    add_reference :logos, :institution, foreign_key: true, null: true
    rename_column :logos, :slug, :filename

    Logo.all.each do |logo|
      institution = Institution.find_by(slug: logo.filename)
      logo.update(institution_id: institution.id) if institution.present?
    end

    [
      [ 'banque-de-france', 'banque_de_france'],
      [ 'bpi-france', 'bpifrance'],
      [ 'cap-emploi', 'cap_emploi'],
      [ 'chambre-d-agriculture', 'chambre_d_agriculture_france' ],
      [ 'conseil-regional-hauts-de-france', 'conseil_regional_hauts_de_france' ],
      [ 'direccte', 'dreets' ],
      [ 'initiative-france', 'initiative_france' ],
      [ 'maisons-de-l-emploi', 'maisons_de_l_emploi'],
      [ 'mediateur-des-entreprises', 'mediation_des_entreprises'],
      [ 'pole-emploi', 'pole_emploi'],
      [ 'reseau-des-missions-locales', 'missions_locales']
    ].each do |logo_filename, institution_slug|
      logo = Logo.find_by(filename: logo_filename)
      institution = Institution.find_by(slug: institution_slug)
      logo.update(institution_id: institution.id) if logo.present? && institution.present?
    end
  end

  def down
    remove_reference :logos, :institution, foreign_key: true, null: true
    rename_column :logos, :filename, :slug
  end
end
