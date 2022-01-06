require 'rails_helper'

describe 'anonymize_old_diagnoses', type: :task do
  let(:anonymized) { I18n.t('attributes.anonymized') }
  let(:three_years_ago) { (3.years - 1.day).ago }
  let(:two_years_ago) { 2.years.ago }

  context 'Diagnoses created 3 years ago' do
    let(:company) { create :company }
    let(:facility) { create :facility, company: company }
    let(:solicitation) { create :solicitation, created_at: three_years_ago }
    let!(:diagnosis) { create :diagnosis_completed, facility: facility, created_at: three_years_ago, solicitation: solicitation }

    before do
      task.invoke
      diagnosis.reload
    end

    it 'anonymize company, visitee and solicitation' do
      expect(diagnosis.company.name).to eq anonymized
      expect(diagnosis.company.siren).to be_nil
      expect(diagnosis.facility.siret).to be_nil
      expect(diagnosis.visitee.email).to be_nil
      expect(diagnosis.visitee.full_name).to eq anonymized
      expect(diagnosis.visitee.phone_number).to eq anonymized
      expect(diagnosis.solicitation.email).to be_nil
      expect(diagnosis.solicitation.full_name).to eq anonymized
      expect(diagnosis.solicitation.phone_number).to eq anonymized
      expect(diagnosis.solicitation.siret).to be_nil
    end
  end

  context 'Diagnoses created less than 3 years ago' do
    let(:company) { create :company }
    let(:facility) { create :facility, company: company }
    let(:solicitation) { create :solicitation }
    let!(:diagnosis) { create :diagnosis_completed, facility: facility, created_at: two_years_ago, solicitation: solicitation }

    before do
      task.invoke
      diagnosis.reload
    end

    it 'Don’t anonymize company, visitee and solicitation' do
      expect(diagnosis.company.name).not_to eq anonymized
      expect(diagnosis.company.siren).not_to be_nil
      expect(diagnosis.facility.siret).not_to be_nil
      expect(diagnosis.visitee.email).not_to be_nil
      expect(diagnosis.visitee.full_name).not_to eq anonymized
      expect(diagnosis.visitee.phone_number).not_to eq anonymized
      expect(diagnosis.solicitation.email).not_to be_nil
      expect(diagnosis.solicitation.full_name).not_to eq anonymized
      expect(diagnosis.solicitation.phone_number).not_to eq anonymized
      expect(diagnosis.solicitation.siret).not_to be_nil
    end
  end

  context 'Company with many diagnoses, one recent and one older than 3 years' do
    let(:company) { create :company }
    let(:facility) { create :facility, company: company }
    let(:solicitation_1) { create :solicitation }
    let(:solicitation_2) { create :solicitation }
    # old diagnosis
    let!(:diagnosis_1) { create :diagnosis_completed, facility: facility, created_at: three_years_ago, solicitation: solicitation_1 }
    # new diagnosis
    let!(:diagnosis_2) { create :diagnosis_completed, facility: facility, created_at: two_years_ago, solicitation: solicitation_2 }

    before do
      task.invoke
      company.reload
      facility.reload
      diagnosis_1.reload
      diagnosis_2.reload
    end

    it 'Anonymize solicitation but not the company' do
      expect(company.name).not_to eq anonymized
      expect(company.siren).not_to be_nil
      expect(facility.siret).not_to be_nil

      expect(diagnosis_1.visitee.email).to be_nil
      expect(diagnosis_1.visitee.full_name).to eq anonymized
      expect(diagnosis_1.visitee.phone_number).to eq anonymized
      expect(diagnosis_1.solicitation.email).to be_nil
      expect(diagnosis_1.solicitation.full_name).to eq anonymized
      expect(diagnosis_1.solicitation.phone_number).to eq anonymized
      expect(diagnosis_1.solicitation.siret).to be_nil

      expect(diagnosis_2.visitee.email).not_to be_nil
      expect(diagnosis_2.visitee.full_name).not_to eq anonymized
      expect(diagnosis_2.visitee.phone_number).not_to eq anonymized
      expect(diagnosis_2.solicitation.email).not_to be_nil
      expect(diagnosis_2.solicitation.full_name).not_to eq anonymized
      expect(diagnosis_2.solicitation.phone_number).not_to eq anonymized
      expect(diagnosis_2.solicitation.siret).not_to be_nil
    end
  end
end
