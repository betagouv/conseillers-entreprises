class AddTitleToSolicitationMailTemplates < ActiveRecord::Migration[8.1]
  def change
    add_column :solicitation_mail_templates, :title, :string

    up_only do
      existing_titles = {
        administrations_collectivites: 'Administrations et collectivités',
        carsat: 'CARSAT',
        creation: 'Création',
        employee_labor_law: 'Droit du travail salarié',
        formalites_asso_agri_sci: 'Formalités Asso/Agri/SCI',
        intermediary: 'Intermédiaire',
        kbis_extract: 'Extrait Kbis',
        mediateurs: 'Médiateurs',
        moderation: 'Modération',
        no_expert: "Pas d'expert",
        no_expert_agri: "Pas d'expert agricole",
        recruitment_foreign_worker: 'Recrutement travailleur étranger',
        retirement_liberal_professions: 'Retraite professions libérales',
        sie_sip_declare_and_pay: 'SIE/SIP déclarer et payer',
        sie_tva_and_others: 'SIE TVA et autres',
        siret: 'Erreur SIRET',
        tns_training: 'Formation TNS'
      }

      SolicitationMailTemplate.find_each do |template|
        title = existing_titles[template.email_type.to_sym] || template.email_type.to_s.tr('_', ' ').capitalize
        template.update_columns(title: title)
      end
    end

    change_column_null :solicitation_mail_templates, :title, false
    add_index :solicitation_mail_templates, :title, unique: true
  end
end
