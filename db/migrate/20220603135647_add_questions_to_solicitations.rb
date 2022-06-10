class AddQuestionsToSolicitations < ActiveRecord::Migration[7.0]
  def change
    create_table :additional_subject_questions do |t|
      t.references :subject, index: true
      t.string :key
      t.integer :position
    end

    create_table :institution_filters do |t|
      t.references :additional_subject_question, index: true
      t.references :institution_filtrable, polymorphic: true, index: true
      t.boolean :filter_value

      t.timestamps null: false
    end

    add_index :institution_filters, [:institution_filtrable_id, :institution_filtrable_type, :additional_subject_question_id], unique: true, name: 'institution_filtrable_additional_subject_question_index'

    up_only do
      [
        {
          key: :recrutement_poste_cadre, subject_id: 44, filters: [
            { slug: 'apec', value: true },
            { slug: 'missions_locales', value: false }
          ]
        },
        {
          key: :recrutement_en_apprentissage, subject_id: 44, filters: [
            { slug: 'missions_locales', value: true },
            { slug: 'cci', value: true },
            { slug: 'cma', value: true },
            { slug: 'dreets', value: true },
            { slug: 'opco-2i', value: true },
            { slug: 'opco-afdas', value: true },
            { slug: 'opco-akto', value: true },
            { slug: 'opco-atlas', value: true },
            { slug: 'opco-construction', value: true },
            { slug: 'opco-entreprises-de-proximite', value: true },
            { slug: 'opcommerce', value: true },
            { slug: 'opco-mobilites', value: true },
            { slug: 'opco-ocapiat', value: true },
            { slug: 'opco-sante', value: true },
            { slug: 'opco-uniformation', value: true },
          ]
        },
        {
          key: :formee_est_salariee_de_lentreprise, subject_id: 45, filters: [
            { slug: 'pole_emploi', value: false }
          ]
        },
        {
          key: :moins_de_10k_restant_a_financer, subject_id: 55, filters: [
            { slug: 'initiative-france', value: false },
            { slug: 'bpifrance', value: false },
            { slug: 'adie', value: true }
          ]
        },
        {
          key: :ameliorer_conditions_travail, subject_id: 55, filters: [
            { slug: 'carsat', value: true }
          ]
        },
        {
          key: :etalement_cotisations_sociales, subject_id: 42, filters: [
            { slug: 'urssaf', value: true },
            { slug: 'dgfip', value: true }
          ]
        },
        {
          key: :entreprise_a_reprendre_trouvee, subject_id: 119, filters: [
            { slug: 'initiative-france', value: true },
          ]
        }
      ].each_with_index do |option, idx|
        adq = AdditionalSubjectQuestion.where(key: option[:key]).first_or_create(subject_id: option[:subject_id], position: idx + 1)
        option[:filters].each do |filter|
          institution = Institution.find_by(slug: filter[:slug])
          adq.institution_filters.where(institution_filtrable: institution).first_or_create(filter_value: filter[:value])
        end
      end
    end
  end
end
