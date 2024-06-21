class ChangeSubjectQuestions < ActiveRecord::Migration[7.0]
  def change
    rename_table('additional_subject_questions', 'subject_questions')
    rename_table('institution_filters', 'subject_answers')
    rename_column('subject_answers', 'institution_filtrable_type', 'subject_questionable_type')
    rename_column('subject_answers', 'institution_filtrable_id', 'subject_questionable_id')
    rename_column('subject_answers', 'additional_subject_question_id', 'subject_question_id')
    add_column :subject_answers, :type, :string
    add_index :subject_answers, :type

    create_table :subject_answer_groupings do |t|
      t.references :institution, null: false, foreign_key: true, index: true
      t.timestamps
    end

    add_reference :subject_answers, :subject_answer_grouping, index: true
    change_column_null :subject_answers, :subject_question_id, false
    change_column_null :subject_questions, :subject_id, false

    reversible do |direction|
      direction.up do
        SubjectAnswer.where(subject_questionable_type: "Institution").find_each do |subject_answer|
          institution_id = subject_answer.subject_questionable_id
          sag = Institution.find(institution_id).subject_answer_groupings.create
          subject_answer.update(
            subject_answer_grouping_id: sag.id,
            type: 'SubjectAnswer::Filter'
          )

          subject_answer.subject_questionable_type = nil
          subject_answer.subject_questionable_id = nil
        end
        ## Création des questions groupées investissement =====================
        #
        # ADIE :
        #   - less_than_10k: true && bank: true
        #   - less_than_10k: true && bank: false
        #   - less_than_10k: false && bank: false
        # Initiative
        #   - less_than_10k: true && bank: true
        #   - less_than_10k: false && bank: true
        # Bpi
        #   - less_than_10k: false && bank: true
        # BDF
        #   - less_than_10k: false && bank: true
        #   - less_than_10k: false && bank: false

        less_than_10k_question_id = SubjectQuestion.find_by(key: 'moins_de_10k_restant_a_financer').id
        bank_question_id = SubjectQuestion.find_by(key: 'financement_bancaire_envisage').id

        adie = Institution.find_by(slug: 'adie')
        adie.subject_answer_groupings.each{ |sag| sag.subject_answers.where(subject_question_id: [less_than_10k_question_id, bank_question_id]).destroy_all }
        adie.subject_answer_groupings.where.missing(:subject_answers).destroy_all

        first= adie.subject_answer_groupings.create
        first.subject_answers = [
          SubjectAnswer::Filter.create(subject_question_id: less_than_10k_question_id, filter_value: true),
          SubjectAnswer::Filter.create(subject_question_id: bank_question_id, filter_value: true)
        ]
        second = adie.subject_answer_groupings.create
        second.subject_answers = [
          SubjectAnswer::Filter.create(subject_question_id: less_than_10k_question_id, filter_value: true),
          SubjectAnswer::Filter.create(subject_question_id: bank_question_id, filter_value: false)
        ]
        third = adie.subject_answer_groupings.create
        third.subject_answers = [
          SubjectAnswer::Filter.create(subject_question_id: less_than_10k_question_id, filter_value: false),
          SubjectAnswer::Filter.create(subject_question_id: bank_question_id, filter_value: false)
        ]

        initiative = Institution.find_by(slug: 'initiative-france')
        initiative.subject_answer_groupings.each{ |sag| sag.subject_answers.where(subject_question_id: [less_than_10k_question_id, bank_question_id]).destroy_all }
        initiative.subject_answer_groupings.where.missing(:subject_answers).destroy_all
        first = initiative.subject_answer_groupings.create
        first.subject_answers = [
          SubjectAnswer::Filter.create(subject_question_id: less_than_10k_question_id, filter_value: true),
          SubjectAnswer::Filter.create(subject_question_id: bank_question_id, filter_value: true)
        ]
        second = initiative.subject_answer_groupings.create
        second.subject_answers = [
          SubjectAnswer::Filter.create(subject_question_id: less_than_10k_question_id, filter_value: false),
          SubjectAnswer::Filter.create(subject_question_id: bank_question_id, filter_value: true)
        ]

        bpi = Institution.find_by(slug: 'bpifrance')
        bpi.subject_answer_groupings.each{ |sag| sag.subject_answers.where(subject_question_id: [less_than_10k_question_id, bank_question_id]).destroy_all }
        bpi.subject_answer_groupings.where.missing(:subject_answers).destroy_all
        first = bpi.subject_answer_groupings.create
        first.subject_answers = [
          SubjectAnswer::Filter.create(subject_question_id: less_than_10k_question_id, filter_value: false),
          SubjectAnswer::Filter.create(subject_question_id: bank_question_id, filter_value: true)
        ]

        bdf = Institution.find_by(slug: 'banque-de-france')
        bdf.subject_answer_groupings.each{ |sag| sag.subject_answers.where(subject_question_id: [less_than_10k_question_id, bank_question_id]).destroy_all }
        bdf.subject_answer_groupings.where.missing(:subject_answers).destroy_all
        first = bdf.subject_answer_groupings.create
        first.subject_answers = [
          SubjectAnswer::Filter.create(subject_question_id: less_than_10k_question_id, filter_value: false),
          SubjectAnswer::Filter.create(subject_question_id: bank_question_id, filter_value: true)
        ]
        second = bdf.subject_answer_groupings.create
        second.subject_answers = [
          SubjectAnswer::Filter.create(subject_question_id: less_than_10k_question_id, filter_value: false),
          SubjectAnswer::Filter.create(subject_question_id: bank_question_id, filter_value: false)
        ]

        ## Création des questions groupées RH =====================
        #
        # CCI
        # - recrutement_premier: true
        # APEC
        # - poste_cadre_question: true && recrutement_identifie: false

        SubjectQuestion.find_by(key: 'recrutement_handicape').update(position: 5)
        SubjectQuestion.find_by(key: 'recrutement_poste_cadre').update(position: 3)
        SubjectQuestion.create(subject_id: 44, key: 'recrutement_premier', position: 1)
        SubjectQuestion.create(subject_id: 44, key: 'recrutement_identifie', position: 4)
        identifie_question = SubjectQuestion.find_by(key: 'recrutement_identifie')
        premier_question = SubjectQuestion.find_by(key: 'recrutement_premier')

        cci = Institution.find_by(slug: 'cci')
        first = cci.subject_answer_groupings.create
        first.subject_answers = [
          SubjectAnswer::Filter.create(subject_question_id: premier_question.id, filter_value: true)
        ]

        apec = Institution.find_by(slug: 'apec')
        first = apec.subject_answer_groupings.first
        # apec a déjà recrutement_poste_cadre: true
        first.subject_answers.push(SubjectAnswer::Filter.create(subject_question_id: identifie_question.id, filter_value: false))

        SubjectAnswer.where(type: nil).update_all(type: 'SubjectAnswer::Item')
      end
      direction.down do
        SubjectAnswer::Filter.where.not(subject_answer_grouping: nil).find_each do |sa|
          institution = sa.subject_answer_grouping.institution
          sa.type = 'SubjectAnswer::Item'
          sa.subject_questionable_id = institution.id
          sa.save
          sa.subject_answer_grouping = nil
        end
      end
    end
  end
end
