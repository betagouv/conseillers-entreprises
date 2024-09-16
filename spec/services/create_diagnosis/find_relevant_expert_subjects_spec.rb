# frozen_string_literal: true

require 'rails_helper'
describe CreateDiagnosis::FindRelevantExpertSubjects do
  describe 'apply_match_filters' do
    let(:institution) { create :institution }
    let!(:es_temoin) { create :expert_subject }
    let(:antenne) { create :antenne, institution: institution }

    subject{ described_class.new(need).apply_match_filters(ExpertSubject.all) }

    context 'accepting_years_of_existence' do
      let(:diagnosis) { create :diagnosis, company: company }
      let(:need) { create :need, diagnosis: diagnosis }
      let!(:es_01) { create :expert_subject }

      describe 'min_years_of_existence' do
        let(:match_filter_01) { create :match_filter, antenne: antenne, min_years_of_existence: 5 }
        let(:match_filter_02) { create :match_filter, institution: institution, min_years_of_existence: 3 }

        context 'with expert filter only' do
          before { es_01.expert.match_filters << match_filter_01 }

          context 'young company' do
            let(:company) { create :company, date_de_creation: 4.years.ago }

            it { is_expected.to contain_exactly(es_temoin) }
          end

          context 'old company' do
            let(:company) { create :company, date_de_creation: 7.years.ago }

            it { is_expected.to contain_exactly(es_01, es_temoin) }
          end
        end

        context 'with antenne filter only' do
          before { es_01.expert.antenne.match_filters << match_filter_01 }

          context 'young company' do
            let(:company) { create :company, date_de_creation: 4.years.ago }

            it { is_expected.to contain_exactly(es_temoin) }
          end

          context 'old company' do
            let(:company) { create :company, date_de_creation: 7.years.ago }

            it { is_expected.to contain_exactly(es_01, es_temoin) }
          end
        end

        context 'with institution filter only' do
          before { es_01.expert.institution.match_filters << match_filter_02 }

          context 'young company' do
            let(:company) { create :company, date_de_creation: 2.years.ago }

            it { is_expected.to contain_exactly(es_temoin) }
          end

          context 'old company' do
            let(:company) { create :company, date_de_creation: 4.years.ago }

            it { is_expected.to contain_exactly(es_01, es_temoin) }
          end
        end

        # TODO les filtres avec des expert passent sans changements
        context 'with antenne and expert filter' do
          before do
            es_01.expert.match_filters << match_filter_01
            es_01.expert.antenne.match_filters << match_filter_02
          end

          context 'young company' do
            let(:company) { create :company, date_de_creation: 2.years.ago }

            it { is_expected.to contain_exactly(es_temoin) }
          end

          context 'old company' do
            let(:company) { create :company, date_de_creation: 5.years.ago }

            it { is_expected.to contain_exactly(es_01, es_temoin) }
          end
        end

        context 'with institution and expert filter' do
          before do
            es_01.expert.match_filters << match_filter_01
            es_01.expert.institution.match_filters << match_filter_02
          end

          context 'young company' do
            let(:company) { create :company, date_de_creation: 2.years.ago }

            it { is_expected.to contain_exactly(es_temoin) }
          end

          context 'old company' do
            let(:company) { create :company, date_de_creation: 5.years.ago }

            it { is_expected.to contain_exactly(es_01, es_temoin) }
          end
        end

        context 'with institution and antenne filter' do
          before do
            es_01.expert.antenne.match_filters << match_filter_01
            es_01.expert.institution.match_filters << match_filter_02
          end

          context 'young company' do
            let(:company) { create :company, date_de_creation: 2.years.ago }

            it { is_expected.to contain_exactly(es_temoin) }
          end

          context 'old company' do
            let(:company) { create :company, date_de_creation: 5.years.ago }

            it { is_expected.to contain_exactly(es_01, es_temoin) }
          end
        end
      end

      context 'max_years_of_existence' do
        let(:match_filter_01) { create :match_filter, :for_antenne, max_years_of_existence: 5 }

        before { es_01.expert.antenne.match_filters << match_filter_01 }

        context 'young company' do
          let(:company) { create :company, date_de_creation: 2.years.ago }

          it { is_expected.to contain_exactly(es_01, es_temoin) }
        end

        context 'old company' do
          let(:company) { create :company, date_de_creation: 7.years.ago }

          it { is_expected.to contain_exactly(es_temoin) }
        end
      end
    end

    context 'effectifs && subject' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:tresorerie_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, antenne: antenne, effectif_max: 10, subjects: [tresorerie_subject] }
      let(:match_filter_02) { create :match_filter, institution: institution, effectif_max: 50, subjects: [tresorerie_subject] }
      let!(:es_01) { create :expert_subject }

      context 'with antenne filter only' do
        let(:code_effectif_ok) { '03' } # 6 à 9 salariés
        let(:code_effectif_ko) { '12' } # 20 à 49 salariés

        before { es_01.expert.antenne.match_filters << match_filter_01 }

        context 'matching nothing' do
          let(:need_subject) { create :subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ko }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end

        context 'matching subject only' do
          let(:need_subject) { tresorerie_subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ko }

          it { is_expected.to contain_exactly(es_temoin) }
        end

        context 'matching effectif only' do
          let(:need_subject) { create :subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ok }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end

        context 'matching subject and effectif' do
          let(:need_subject) { tresorerie_subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ok }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end
      end

      context 'with antenne and institution filter' do
        let(:code_effectif_ok) { '03' } # 6 à 9 salariés
        let(:code_effectif_ko) { '12' } # 20 à 49 salariés

        before do
          es_01.expert.antenne.match_filters << match_filter_01
          es_01.expert.institution.match_filters << match_filter_02
        end

        context 'matching nothing' do
          let(:need_subject) { create :subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ko }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end

        context 'matching subject only' do
          let(:need_subject) { tresorerie_subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ko }

          it { is_expected.to contain_exactly(es_temoin) }
        end

        context 'matching effectif only' do
          let(:need_subject) { create :subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ok }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end

        context 'matching subject and effectif' do
          let(:need_subject) { tresorerie_subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ok }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end
      end

      context 'with institution filter only' do
        let(:code_effectif_ok) { '03' } # 6 à 9 salariés
        let(:code_effectif_ko) { '32' } # 250 à 499 salariés

        before { es_01.expert.institution.match_filters << match_filter_02 }

        context 'matching nothing' do
          let(:need_subject) { create :subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ko }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end

        context 'matching subject only' do
          let(:need_subject) { tresorerie_subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ko }

          it { is_expected.to contain_exactly(es_temoin) }
        end

        context 'matching effectif only' do
          let(:need_subject) { create :subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ok }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end

        context 'matching subject and effectif' do
          let(:need_subject) { tresorerie_subject }
          let(:facility) { create :facility, code_effectif: code_effectif_ok }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end
      end
    end

    context 'code naf && subject' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:difficulte_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, :for_antenne, accepted_naf_codes: ['1101Z', '1102A', '1102B'], subjects: [difficulte_subject] }
      let(:match_filter_excluding_naf) { create :match_filter, :for_antenne, excluded_naf_codes: ['9001Z'], subjects: [difficulte_subject] }

      let!(:es_including_naf) { create :expert_subject }
      let!(:es_excluding_naf) { create :expert_subject }

      before do
        es_including_naf.expert.antenne.match_filters << match_filter_01
        es_excluding_naf.expert.antenne.match_filters << match_filter_excluding_naf
      end

      context 'matching subject only' do
        let(:need_subject) { difficulte_subject }
        let(:facility) { create :facility, naf_code: '2202A' }

        it { is_expected.to contain_exactly(es_temoin, es_excluding_naf) }
      end

      context 'matching accepted naf only' do
        let(:need_subject) { create :subject }
        let(:facility) { create :facility, naf_code: '1102A' }

        it { is_expected.to contain_exactly(es_temoin, es_including_naf, es_excluding_naf) }
      end

      context 'matching excluded naf only' do
        let(:need_subject) { create :subject }
        let(:facility) { create :facility, naf_code: '9001Z' }

        it { is_expected.to contain_exactly(es_temoin, es_including_naf, es_excluding_naf) }
      end

      context 'matching accepted naf and subject' do
        let(:need_subject) { difficulte_subject }
        let(:facility) { create :facility, naf_code: '1102A' }

        it { is_expected.to contain_exactly(es_temoin, es_including_naf, es_excluding_naf) }
      end

      context 'matching excluded naf and subject' do
        let(:need_subject) { difficulte_subject }
        let(:facility) { create :facility, naf_code: '9001Z' }

        it { is_expected.to contain_exactly(es_temoin) }
      end

      context 'matching nothing' do
        let(:need_subject) { create :subject }
        let(:facility) { create :facility, naf_code: '2202A' }

        it { is_expected.to contain_exactly(es_temoin, es_including_naf, es_excluding_naf) }
      end
    end

    context 'legal form && subject' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:facility) { create :facility, company: company }

      let(:company) { create :company, legal_form_code: '2202A' }
      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:difficulte_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, :for_antenne, accepted_legal_forms: %w[4160 6533 6534], subjects: [difficulte_subject] }
      let(:match_filter_excluding_legal_forms) { create :match_filter, :for_antenne, excluded_legal_forms: %w[5499], subjects: [difficulte_subject] }

      let!(:es_including) { create :expert_subject }
      let!(:es_excluding) { create :expert_subject }

      before do
        es_including.expert.antenne.match_filters << match_filter_01
        es_excluding.expert.antenne.match_filters << match_filter_excluding_legal_forms
      end

      context 'matching subject only' do
        let(:need_subject) { difficulte_subject }
        let(:company) { create :company, legal_form_code: '1000' }

        it { is_expected.to contain_exactly(es_temoin, es_excluding) }
      end

      context 'matching accepted legal form only' do
        let(:need_subject) { create :subject }
        let(:company) { create :company, legal_form_code: '6533' }

        it { is_expected.to contain_exactly(es_temoin, es_including, es_excluding) }
      end

      context 'matching excluded legal form only' do
        let(:need_subject) { create :subject }
        let(:company) { create :company, legal_form_code: '5499' }

        it { is_expected.to contain_exactly(es_temoin, es_including, es_excluding) }
      end

      context 'matching accepted legal form and subject' do
        let(:need_subject) { difficulte_subject }
        let(:company) { create :company, legal_form_code: '6533' }

        it { is_expected.to contain_exactly(es_temoin, es_including, es_excluding) }
      end

      context 'matching excluded legal form and subject' do
        let(:need_subject) { difficulte_subject }
        let(:company) { create :company, legal_form_code: '5499' }

        it { is_expected.to contain_exactly(es_temoin) }
      end

      context 'matching nothing' do
        let(:need_subject) { create :subject }
        let(:company) { create :company, legal_form_code: '1000' }

        it { is_expected.to contain_exactly(es_temoin, es_including, es_excluding) }
      end
    end

    context 'many filters' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:need) { create :need, diagnosis: diagnosis }

      let(:match_filter_01) { create :match_filter, :for_antenne, effectif_min: 10 }
      let(:match_filter_02) { create :match_filter, :for_antenne, min_years_of_existence: 3 }
      let!(:es_01) { create :expert_subject }

      before do
        es_01.expert.antenne.match_filters << match_filter_01
        es_01.expert.antenne.match_filters << match_filter_02
      end

      # On n'envoie pas si on n'a pas l'info
      context 'no facility filter data' do
        let(:facility) { create :facility, code_effectif: nil, company: create(:company, date_de_creation: nil) }

        it { is_expected.to contain_exactly(es_temoin) }
      end

      context 'matching none' do
        # 6 à 9 salariés
        let(:facility) { create :facility, code_effectif: '03', company: create(:company, date_de_creation: 2.years.ago) }

        it { is_expected.to contain_exactly(es_temoin) }
      end

      context 'matching min_years_of_existence' do
        let(:facility) { create :facility, company: create(:company, date_de_creation: 4.years.ago) }

        it { is_expected.to contain_exactly(es_temoin, es_01) }
      end

      context 'matching effectif_min' do
        let(:facility) { create :facility, code_effectif: '11' } # 10 à 19 salariés

        it { is_expected.to contain_exactly(es_temoin, es_01) }
      end

      context 'matching both' do
        # 10 à 19 salariés
        let(:facility) { create :facility, code_effectif: '11', company: create(:company, date_de_creation: 4.years.ago) }

        it { is_expected.to contain_exactly(es_temoin, es_01) }
      end
    end

    context 'many subjects filter' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:facility) { create :facility, company: create(:company, date_de_creation: date_de_creation_company) }

      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:difficulte_subject) { create :subject }
      let!(:rh_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, :for_antenne, min_years_of_existence: 3, subjects: [difficulte_subject, rh_subject] }

      let!(:es_01) { create :expert_subject }

      before do
        es_01.expert.antenne.match_filters << match_filter_01
      end

      context 'subject with criteria ok' do
        let(:need_subject) { difficulte_subject }
        let(:date_de_creation_company) { 4.years.ago }

        it { is_expected.to contain_exactly(es_temoin, es_01) }
      end

      context 'subject with criteria ko' do
        let(:need_subject) { difficulte_subject }
        let(:date_de_creation_company) { 1.year.ago }

        it { is_expected.to contain_exactly(es_temoin) }
      end

      context 'only min_years_of_existence criteria matching' do
        let(:need_subject) { create(:subject) }
        let(:date_de_creation_company) { 4.years.ago }

        it { is_expected.to contain_exactly(es_temoin, es_01) }
      end

      context 'no criteria matching' do
        let(:need_subject) { create(:subject) }
        let(:date_de_creation_company) { 1.year.ago }

        it { is_expected.to contain_exactly(es_temoin, es_01) }
      end
    end

    context 'BPI like' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let!(:facility) { create :facility, code_effectif: code_effectif, company: create(:company, date_de_creation: date_de_creation_company) }

      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:rh_subject) { create :subject }
      let!(:eau_subject) { create :subject }
      let!(:energie_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, :for_antenne, min_years_of_existence: 3, subjects: [rh_subject] }
      let(:match_filter_02) { create :match_filter, :for_antenne, min_years_of_existence: 3, effectif_max: 50, subjects: [eau_subject, energie_subject] }

      let!(:es_01) { create :expert_subject }

      before do
        es_01.expert.antenne.match_filters << match_filter_01
        es_01.expert.antenne.match_filters << match_filter_02
      end

      context 'with non filtered subject' do
        context 'other subject + 1 year existence + effectif 50' do
          let(:need_subject) { create(:subject) }
          let(:date_de_creation_company) { 1.year.ago }
          let(:code_effectif) { '21' }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end
      end

      context 'with non environmental subject' do
        context 'rh_subject + 1 year existence + effectif 40' do
          let(:need_subject) { rh_subject }
          let(:date_de_creation_company) { 1.year.ago }
          let(:code_effectif) { '12' }

          it { is_expected.to contain_exactly(es_temoin) }
        end

        context 'rh_subject + 1 year existence + effectif 50' do
          let(:need_subject) { rh_subject }
          let(:date_de_creation_company) { 1.year.ago }
          let(:code_effectif) { '21' }

          it { is_expected.to contain_exactly(es_temoin) }
        end

        context 'rh_subject + 5 year existence + effectif 50' do
          let(:need_subject) { rh_subject }
          let(:date_de_creation_company) { 5.years.ago }
          let(:code_effectif) { '21' }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end
      end

      context 'with environmental subject' do
        context 'eau subject + 1 year existence + effectif 40' do
          let(:need_subject) { eau_subject }
          let(:date_de_creation_company) { 1.year.ago }
          let(:code_effectif) { '12' }

          it { is_expected.to contain_exactly(es_temoin) }
        end

        context 'eau subject + 5 year existence + effectif 40' do
          let(:need_subject) { eau_subject }
          let(:date_de_creation_company) { 5.years.ago }
          let(:code_effectif) { '12' }

          it { is_expected.to contain_exactly(es_temoin, es_01) }
        end

        context 'eau subject + 5 year existence + effectif 50' do
          let(:need_subject) { eau_subject }
          let(:date_de_creation_company) { 5.years.ago }
          let(:code_effectif) { '21' }

          it { is_expected.to contain_exactly(es_temoin) }
        end
      end
    end
  end

  describe 'apply_subject_question_filters' do
    subject{ described_class.new(need).apply_subject_question_filters(ExpertSubject.of_subject(need.subject)) }

    context 'fictive case' do
      let(:common_subject) { create :subject }
      let(:additional_question) { create :subject_question, subject: common_subject }

      let(:institution_ok) { create :institution }
      let!(:institution_ok_grouping) { create :subject_answer_grouping, institution: institution_ok }
      let!(:es_answer_ok) { create :expert_subject, subject: common_subject, expert: (create :expert, antenne: (create :antenne, institution: institution_ok)) }
      let(:institution_ko) { create :institution }
      let!(:institution_ko_grouping) { create :subject_answer_grouping, institution: institution_ko }
      let!(:es_answer_ko) { create :expert_subject, subject: common_subject, expert: (create :expert, antenne: (create :antenne, institution: institution_ko)) }
      let!(:es_temoin) { create :expert_subject, subject: common_subject }

      let(:need) { create :need, subject: common_subject }

      before do
        need.subject_answers = subject_answers
        institution_ok_grouping.subject_answers = institution_ok_subject_answers
        institution_ko_grouping.subject_answers = institution_ko_subject_answers
      end

      context 'need with simple question filter' do
        let(:subject_answers) { [create(:need_subject_answer, subject_question: additional_question, filter_value: true, subject_questionable: need)] }
        let(:institution_ok_subject_answers) { [create(:subject_answer_filter, subject_question: additional_question, filter_value: true)] }
        let(:institution_ko_subject_answers) { [create(:subject_answer_filter, subject_question: additional_question, filter_value: false)] }

        it { is_expected.to contain_exactly(es_temoin, es_answer_ok) }
      end

      context 'need with complex question filter' do
        let(:other_question) { create :subject_question, subject: common_subject }

        let(:subject_answers) do
          [
            create(:need_subject_answer, subject_question: additional_question, filter_value: true, subject_questionable: need),
            create(:need_subject_answer, subject_question: other_question, filter_value: false, subject_questionable: need)
          ]
        end
        let(:institution_ok_subject_answers) do
          [
            create(:subject_answer_filter, subject_question: additional_question, filter_value: true),
            create(:subject_answer_filter, subject_question: other_question, filter_value: false)
          ]
        end
        let(:institution_ko_subject_answers) do
          [
            create(:subject_answer_filter, subject_question: additional_question, filter_value: false),
            create(:subject_answer_filter, subject_question: other_question, filter_value: false)
          ]
        end

        context 'only one grouping' do
          it { is_expected.to contain_exactly(es_temoin, es_answer_ok) }
        end

        context 'many groupings' do
          let!(:institution_ok_falsy_grouping) { create :subject_answer_grouping, institution: institution_ok }
          let(:institution_ok_falsy_subject_answers) do
            [
              create(:subject_answer_filter, subject_question: additional_question, filter_value: true),
              create(:subject_answer_filter, subject_question: other_question, filter_value: true)
            ]
          end

          before { institution_ok_falsy_grouping.subject_answers = institution_ok_falsy_subject_answers }

          # Du moment qu'il y a un bon grouping, meme si les autres le sont pas, ça marche
          it { is_expected.to contain_exactly(es_temoin, es_answer_ok) }
        end
      end

      context 'need no question filter' do
        let(:subject_answers) { [] }
        let!(:institution_ok_subject_answers) { [create(:subject_answer_filter, subject_question: additional_question, filter_value: true)] }
        let!(:institution_ko_subject_answers) { [create(:subject_answer_filter, subject_question: additional_question, filter_value: false)] }

        it { is_expected.to contain_exactly(es_temoin, es_answer_ok, es_answer_ko) }
      end
    end

    context 'real practical case' do
      # moins de 10 000 + oui banque = Adie, Initiative
      # moins de 10 000 + non banque = Adie
      # plus de 10 000 + oui banque = Bpi, BDF, Initiative
      # plus de 10 000 + non banque = BDF, Adie

      let(:investment_subject) { create :subject, label: 'Investissement' }
      let(:less_than_10k_question) { create :subject_question, key: 'moins_de_10k_restant_a_financer', subject: investment_subject }
      let(:bank_question) { create :subject_question, key: 'financement_bancaire_envisage', subject: investment_subject }

      let(:adie) { create :institution, slug: 'adie' }
      let!(:adie_grouping_1) { create :subject_answer_grouping, institution: adie }
      let!(:adie_grouping_2) { create :subject_answer_grouping, institution: adie }
      let!(:adie_grouping_3) { create :subject_answer_grouping, institution: adie }
      let!(:es_adie) { create :expert_subject, expert: create(:expert, institution: adie), subject: investment_subject }
      let(:initiative) { create :institution, slug: 'initiative-france' }
      let!(:initiative_grouping_1) { create :subject_answer_grouping, institution: initiative }
      let!(:initiative_grouping_2) { create :subject_answer_grouping, institution: initiative }
      let!(:es_initiative) { create :expert_subject, expert: create(:expert, institution: initiative), subject: investment_subject }
      let(:bpi) { create :institution, slug: 'bpifrance' }
      let!(:bpi_grouping) { create :subject_answer_grouping, institution: bpi }
      let!(:es_bpi) { create :expert_subject, expert: create(:expert, institution: bpi), subject: investment_subject }
      let(:bdf) { create :institution, slug: 'banque-de-france' }
      let!(:bdf_grouping_1) { create :subject_answer_grouping, institution: bdf }
      let!(:bdf_grouping_2) { create :subject_answer_grouping, institution: bdf }
      let!(:es_bdf) { create :expert_subject, expert: create(:expert, institution: bdf), subject: investment_subject }

      let(:need) { create :need, subject: investment_subject }

      before do
        adie_grouping_1.subject_answers = [create(:subject_answer_filter, subject_question: less_than_10k_question, filter_value: true), create(:subject_answer_filter, subject_question: bank_question, filter_value: true)]
        adie_grouping_2.subject_answers = [create(:subject_answer_filter, subject_question: less_than_10k_question, filter_value: true), create(:subject_answer_filter, subject_question: bank_question, filter_value: false)]
        adie_grouping_3.subject_answers = [create(:subject_answer_filter, subject_question: less_than_10k_question, filter_value: false), create(:subject_answer_filter, subject_question: bank_question, filter_value: false)]
        initiative_grouping_1.subject_answers = [create(:subject_answer_filter, subject_question: less_than_10k_question, filter_value: true), create(:subject_answer_filter, subject_question: bank_question, filter_value: true)]
        initiative_grouping_2.subject_answers = [create(:subject_answer_filter, subject_question: less_than_10k_question, filter_value: false), create(:subject_answer_filter, subject_question: bank_question, filter_value: true)]
        bpi_grouping.subject_answers = [create(:subject_answer_filter, subject_question: less_than_10k_question, filter_value: false), create(:subject_answer_filter, subject_question: bank_question, filter_value: true)]
        bdf_grouping_1.subject_answers = [create(:subject_answer_filter, subject_question: less_than_10k_question, filter_value: false), create(:subject_answer_filter, subject_question: bank_question, filter_value: true)]
        bdf_grouping_2.subject_answers = [create(:subject_answer_filter, subject_question: less_than_10k_question, filter_value: false), create(:subject_answer_filter, subject_question: bank_question, filter_value: false)]
      end

      describe 'moins de 10 000 + oui banque' do
        before do
          need.subject_answers.create(subject_question: less_than_10k_question, filter_value: true)
          need.subject_answers.create(subject_question: bank_question, filter_value: true)
        end

        it { is_expected.to contain_exactly(es_adie, es_initiative) }
      end

      describe 'moins de 10 000 + non banque' do
        before do
          need.subject_answers.create(subject_question: less_than_10k_question, filter_value: true)
          need.subject_answers.create(subject_question: bank_question, filter_value: false)
        end

        context 'no other institution filters' do
          it { is_expected.to contain_exactly(es_adie) }
        end

        context 'with other institution filter' do
          before do
            create(:subject_answer_grouping, institution: initiative)
          end

          it { is_expected.to contain_exactly(es_adie) }
        end
      end

      describe 'plus de 10 000 + oui banque' do
        before do
          need.subject_answers.create(subject_question: less_than_10k_question, filter_value: false)
          need.subject_answers.create(subject_question: bank_question, filter_value: true)
        end

        it { is_expected.to contain_exactly(es_bpi, es_bdf, es_initiative) }
      end

      describe 'plus de 10 000 + non banque' do
        before do
          need.subject_answers.create(subject_question: less_than_10k_question, filter_value: false)
          need.subject_answers.create(subject_question: bank_question, filter_value: false)
        end

        it { is_expected.to contain_exactly(es_bdf, es_adie) }
      end
    end
  end

  describe 'call' do
    subject{ described_class.new(need).call }

    let(:diagnosis) { create :diagnosis, company: company }
    let(:need) { create :need, diagnosis: diagnosis }

    let!(:es_always) do
      create :expert_subject,
             institution_subject: create(:institution_subject, subject: the_subject, institution: create(:institution)),
             expert: create(:expert, communes: communes)
    end

    let!(:es_never) do
      create :expert_subject,
             institution_subject: create(:institution_subject, subject: the_subject, institution: create(:institution)),
             expert: create(:expert)
    end

    let!(:es_cci) do
      create :expert_subject,
             institution_subject: create(:institution_subject, subject: the_subject, institution: create(:institution, name: 'cci')),
             expert: create(:expert, communes: communes)
    end

    let!(:es_cma) do
      create :expert_subject,
             institution_subject: create(:institution_subject, subject: the_subject, institution: create(:institution, name: 'cma')),
             expert: create(:expert, communes: communes)
    end

    context 'no registre' do
      let(:company) { create :company, inscrit_rcs: true, inscrit_rm: true }
      let(:the_subject) { need.subject }
      let(:communes) { [need.facility.commune] }

      it{ is_expected.to contain_exactly(es_always, es_cci, es_cma) }
    end
  end
end
