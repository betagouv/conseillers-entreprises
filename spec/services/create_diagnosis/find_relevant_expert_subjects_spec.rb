# frozen_string_literal: true

require 'rails_helper'
describe CreateDiagnosis::FindRelevantExpertSubjects do
  describe 'apply_match_filters' do
    subject{ described_class.new(need).apply_match_filters(ExpertSubject.all) }

    let!(:es_temoin) { create :expert_subject }

    describe 'accepting_years_of_existence' do
      let(:diagnosis) { create :diagnosis, company: company }
      let(:need) { create :need, diagnosis: diagnosis }
      let!(:es_01) { create :expert_subject }

      context 'min_years_of_existence' do
        let(:match_filter_01) { create :match_filter, min_years_of_existence: 3 }

        before { es_01.expert.antenne.match_filters << match_filter_01 }

        context 'young company' do
          let(:company) { create :company, date_de_creation: 2.years.ago }

          it { is_expected.to match_array [es_temoin] }
        end

        context 'old company' do
          let(:company) { create :company, date_de_creation: 7.years.ago }

          it { is_expected.to match_array [es_01, es_temoin] }
        end
      end

      context 'max_years_of_existence' do
        let(:match_filter_01) { create :match_filter, max_years_of_existence: 5 }

        before { es_01.expert.antenne.match_filters << match_filter_01 }

        context 'young company' do
          let(:company) { create :company, date_de_creation: 2.years.ago }

          it { is_expected.to match_array [es_01, es_temoin] }
        end

        context 'old company' do
          let(:company) { create :company, date_de_creation: 7.years.ago }

          it { is_expected.to match_array [es_temoin] }
        end
      end
    end

    context 'effectifs && subject' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:tresorerie_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, effectif_max: 20, subjects: [tresorerie_subject] }
      let!(:es_01) { create :expert_subject }

      before { es_01.expert.antenne.match_filters << match_filter_01 }

      context 'matching nothing' do
        let(:need_subject) { create :subject }
        let(:facility) { create :facility, code_effectif: '12' }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'matching subject only' do
        let(:facility) { create :facility, code_effectif: '12' }
        let(:need_subject) { tresorerie_subject }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'matching effectif only' do
        let(:need_subject) { create :subject }
        let(:facility) { create :facility, code_effectif: '11' }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'matching subject and effectif' do
        let(:need_subject) { tresorerie_subject }
        let(:facility) { create :facility, code_effectif: '11' }

        it { is_expected.to match_array [es_temoin, es_01] }
      end
    end

    context 'code naf && subject' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:difficulte_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, accepted_naf_codes: ['1101Z', '1102A', '1102B'], subjects: [difficulte_subject] }
      let!(:es_01) { create :expert_subject }

      before { es_01.expert.antenne.match_filters << match_filter_01 }

      context 'matching subject only' do
        let(:need_subject) { difficulte_subject }
        let(:facility) { create :facility, naf_code: '2202A' }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'matching naf only' do
        let(:need_subject) { create :subject }
        let(:facility) { create :facility, naf_code: '1102A' }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'matching naf and subject' do
        let(:need_subject) { difficulte_subject }
        let(:facility) { create :facility, naf_code: '1102A' }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'matching nothing' do
        let(:need_subject) { create :subject }
        let(:facility) { create :facility, naf_code: '2202A' }

        it { is_expected.to match_array [es_temoin, es_01] }
      end
    end

    context 'legal form && subject' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:facility) { create :facility, company: company }

      let(:company) { create :company, legal_form_code: '2202A' }
      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:difficulte_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, accepted_legal_forms: %w[4 6], subjects: [difficulte_subject] }
      let!(:es_01) { create :expert_subject }

      before { es_01.expert.antenne.match_filters << match_filter_01 }

      context 'matching subject only' do
        let(:need_subject) { difficulte_subject }
        let(:company) { create :company, legal_form_code: '1000' }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'matching legal form only' do
        let(:need_subject) { create :subject }
        let(:company) { create :company, legal_form_code: '6533' }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'matching legal form and subject' do
        let(:need_subject) { difficulte_subject }
        let(:company) { create :company, legal_form_code: '6533' }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'matching nothing' do
        let(:need_subject) { create :subject }
        let(:company) { create :company, legal_form_code: '1000' }

        it { is_expected.to match_array [es_temoin, es_01] }
      end
    end

    context 'many filters' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:need) { create :need, diagnosis: diagnosis }

      let(:match_filter_01) { create :match_filter, effectif_min: 10 }
      let(:match_filter_02) { create :match_filter, min_years_of_existence: 3 }
      let!(:es_01) { create :expert_subject }

      before do
        es_01.expert.antenne.match_filters << match_filter_01
        es_01.expert.antenne.match_filters << match_filter_02
      end

      # On n'envoie pas si on n'a pas l'info
      context 'no facility filter data' do
        let(:facility) { create :facility, code_effectif: nil, company: create(:company, date_de_creation: nil) }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'matching none' do
        let(:facility) { create :facility, code_effectif: '03', company: create(:company, date_de_creation: 2.years.ago) }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'matching min_years_of_existence' do
        let(:facility) { create :facility, company: create(:company, date_de_creation: 4.years.ago) }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'matching effectif_min' do
        let(:facility) { create :facility, code_effectif: '11' }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'matching both' do
        let(:facility) { create :facility, code_effectif: '11', company: create(:company, date_de_creation: 4.years.ago) }

        it { is_expected.to match_array [es_temoin, es_01] }
      end
    end

    context 'many subjects filter' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let(:facility) { create :facility, company: create(:company, date_de_creation: date_de_creation_company) }

      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:difficulte_subject) { create :subject }
      let!(:rh_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, min_years_of_existence: 3, subjects: [difficulte_subject, rh_subject] }

      let!(:es_01) { create :expert_subject }

      before do
        es_01.expert.antenne.match_filters << match_filter_01
      end

      context 'subject with criteria ok' do
        let(:need_subject) { difficulte_subject }
        let(:date_de_creation_company) { 4.years.ago }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'subject with criteria ko' do
        let(:need_subject) { difficulte_subject }
        let(:date_de_creation_company) { 1.year.ago }

        it { is_expected.to match_array [es_temoin] }
      end

      context 'only min_years_of_existence criteria matching' do
        let(:need_subject) { create(:subject) }
        let(:date_de_creation_company) { 4.years.ago }

        it { is_expected.to match_array [es_temoin, es_01] }
      end

      context 'no criteria matching' do
        let(:need_subject) { create(:subject) }
        let(:date_de_creation_company) { 1.year.ago }

        it { is_expected.to match_array [es_temoin, es_01] }
      end
    end

    context 'BPI like' do
      let(:diagnosis) { create :diagnosis, facility: facility }
      let!(:facility) { create :facility, code_effectif: code_effectif, company: create(:company, date_de_creation: date_de_creation_company) }

      let(:need) { create :need, diagnosis: diagnosis, subject: need_subject }

      let!(:rh_subject) { create :subject }
      let!(:eau_subject) { create :subject }
      let!(:energie_subject) { create :subject }
      let(:match_filter_01) { create :match_filter, min_years_of_existence: 3, subjects: [rh_subject] }
      let(:match_filter_02) { create :match_filter, min_years_of_existence: 3, effectif_max: 50, subjects: [eau_subject, energie_subject] }

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

          it { is_expected.to match_array [es_temoin, es_01] }
        end
      end

      context 'with non environmental subject' do
        context 'rh_subject + 1 year existence + effectif 40' do
          let(:need_subject) { rh_subject }
          let(:date_de_creation_company) { 1.year.ago }
          let(:code_effectif) { '12' }

          it { is_expected.to match_array [es_temoin] }
        end

        context 'rh_subject + 1 year existence + effectif 50' do
          let(:need_subject) { rh_subject }
          let(:date_de_creation_company) { 1.year.ago }
          let(:code_effectif) { '21' }

          it { is_expected.to match_array [es_temoin] }
        end

        context 'rh_subject + 5 year existence + effectif 50' do
          let(:need_subject) { rh_subject }
          let(:date_de_creation_company) { 5.years.ago }
          let(:code_effectif) { '21' }

          it { is_expected.to match_array [es_temoin, es_01] }
        end
      end

      context 'with environmental subject' do
        context 'eau subject + 1 year existence + effectif 40' do
          let(:need_subject) { eau_subject }
          let(:date_de_creation_company) { 1.year.ago }
          let(:code_effectif) { '12' }

          it { is_expected.to match_array [es_temoin] }
        end

        context 'eau subject + 5 year existence + effectif 40' do
          let(:need_subject) { eau_subject }
          let(:date_de_creation_company) { 5.years.ago }
          let(:code_effectif) { '12' }

          it { is_expected.to match_array [es_temoin, es_01] }
        end

        context 'eau subject + 5 year existence + effectif 50' do
          let(:need_subject) { eau_subject }
          let(:date_de_creation_company) { 5.years.ago }
          let(:code_effectif) { '21' }

          it { is_expected.to match_array [es_temoin] }
        end
      end
    end
  end

  describe 'apply_institution_filters' do
    subject{ described_class.new(need).apply_institution_filters(ExpertSubject.all) }

    let(:common_subject) { create :subject }
    let(:additional_question) { create :additional_subject_question, subject: common_subject }

    let(:institution_filter_ok) { create :institution }
    let!(:es_filter_ok) { create :expert_subject, expert: (create :expert, antenne: (create :antenne, institution: institution_filter_ok)) }
    let(:institution_filter_ko) { create :institution }
    let!(:es_filter_ko) { create :expert_subject, expert: (create :expert, antenne: (create :antenne, institution: institution_filter_ko)) }
    let!(:es_temoin) { create :expert_subject }

    let(:need) { create :need }

    context 'need with filter' do
      before do
        need.institution_filters.create(additional_subject_question: additional_question, filter_value: true)
        institution_filter_ok.institution_filters.create(additional_subject_question: additional_question, filter_value: true)
        institution_filter_ko.institution_filters.create(additional_subject_question: additional_question, filter_value: false)
      end

      it { is_expected.to match_array [es_temoin, es_filter_ok] }
    end

    context 'need no filter' do
      before do
        institution_filter_ok.institution_filters.create(additional_subject_question: additional_question, filter_value: true)
        institution_filter_ko.institution_filters.create(additional_subject_question: additional_question, filter_value: false)
      end

      it { is_expected.to match_array [es_temoin, es_filter_ok, es_filter_ko] }
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

      it{ is_expected.to match_array [es_always, es_cci, es_cma] }
    end
  end
end
