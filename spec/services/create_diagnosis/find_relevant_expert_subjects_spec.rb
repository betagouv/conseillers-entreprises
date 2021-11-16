# frozen_string_literal: true

require 'rails_helper'
describe CreateDiagnosis::FindRelevantExpertSubjects do
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
