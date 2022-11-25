# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Diagnosis do
  it do
    is_expected.to have_many :needs
    is_expected.to belong_to :facility
  end

  describe 'custom validations' do
    describe 'step_needs_has_visit' do
      subject(:diagnosis) { build :diagnosis, step: :needs, visitee: visitee, happened_on: happened_on }

      before { diagnosis.validate }

      context 'without visitee' do
        let(:visitee) { nil }
        let(:happened_on) { Time.now }

        it { is_expected.not_to be_valid }
        it { expect(diagnosis.errors.details).to eq({ 'facility.company.facilities': [{ error: :invalid }], 'facility.diagnoses': [{ error: :invalid }], visitee: [{ error: :blank }] }) }
      end

      context 'without happened_on' do
        let(:visitee) { build :contact, :with_phone_number }
        let(:happened_on) { nil }

        it { is_expected.not_to be_valid }
        it { expect(diagnosis.errors.details).to eq({ 'facility.company.facilities': [{ error: :invalid }], 'facility.diagnoses': [{ error: :invalid }], happened_on: [{ error: :blank }], 'visitee.diagnoses': [{ error: :invalid }] }) }
      end

      context 'with needs' do
        let(:visitee) { build :contact, :with_phone_number }
        let(:happened_on) { Time.now }

        it { is_expected.to be_valid }
      end
    end

    describe 'step_matches_has_needs_attributes' do
      subject(:diagnosis) { build :diagnosis, step: :matches, needs: needs }

      before { diagnosis.validate }

      context 'missing needs' do
        let(:needs) { [] }

        it { is_expected.not_to be_valid }
        it { expect(diagnosis.errors.details).to eq({ 'facility.company.facilities': [{ error: :invalid }], 'facility.diagnoses': [{ error: :invalid }], needs: [{ error: :blank }], 'visitee.diagnoses': [{ error: :invalid }] }) }
      end

      context 'with needs' do
        let(:needs) { build_list :need, 1 }

        it { is_expected.to be_valid }
      end
    end

    describe 'step_completed_has_matches' do
      subject(:diagnosis) { build :diagnosis, step: :completed }

      context 'no matches' do
        it { is_expected.not_to be_valid }
      end

      context 'with some need without matches' do
        before do
          diagnosis.needs << build(:need, matches: [build(:match)])
          diagnosis.needs << build(:need)
        end

        it { is_expected.not_to be_valid }
      end

      context 'with matches' do
        before { diagnosis.needs << build(:need, matches: [build(:match)]) }

        it { is_expected.to be_valid }
      end
    end

    describe 'step_completed_has_advisor' do
      subject(:diagnosis) { build :diagnosis, solicitation: solicitation, step: :completed, needs: [build(:need, matches: [build(:match)])], advisor: advisor }

      let(:solicitation) { build :solicitation }

      before { diagnosis.validate }

      context 'without advisor' do
        let(:advisor) { nil }

        it { is_expected.not_to be_valid }
        it { expect(diagnosis.errors.details).to eq({ advisor: [{ error: :blank }], 'facility.company.facilities': [{ error: :invalid }], 'facility.diagnoses': [{ error: :invalid }], 'visitee.diagnoses': [{ error: :invalid }] }) }
      end

      context 'with advisor' do
        let(:advisor) { build :user }

        it { is_expected.to be_valid }
      end
    end

    describe 'without_solicitation_has_advisor' do
      subject(:diagnosis) { build :diagnosis, solicitation: nil, advisor: advisor }

      before { diagnosis.validate }

      context 'without advisor' do
        let(:advisor) { nil }

        it { is_expected.not_to be_valid }
        it { expect(diagnosis.errors.details).to eq({ advisor: [{ error: :blank }], 'facility.company.facilities': [{ error: :invalid }], 'facility.diagnoses': [{ error: :invalid }], 'visitee.diagnoses': [{ error: :invalid }] }) }
      end

      context 'with advisor' do
        let(:advisor) { build :user }

        it { is_expected.to be_valid }
      end
    end

    describe 'only one diagnosis by solicitation' do
      let(:solicitation) { create :solicitation }
      let!(:another_diagnosis) { create :diagnosis, solicitation: solicitation }

      subject(:diagnosis) { build :diagnosis, solicitation: solicitation }

      it { is_expected.not_to be_valid }
    end
  end

  describe 'scopes' do
    describe 'in progress' do
      subject { described_class.in_progress.count }

      let!(:diagnosis_completed) { create :diagnosis_completed }
      let!(:diagnosis_needs) { create :diagnosis, step: :needs }
      let!(:need) { create :need, diagnosis: create(:diagnosis) }

      it { is_expected.to eq 2 }
    end

    describe 'completed' do
      subject { described_class.completed.count }

      let!(:diagnosis_completed_1) { create :diagnosis_completed }
      let!(:diagnosis_completed_2) { create :diagnosis_completed }
      let!(:need) { create :need, diagnosis: create(:diagnosis) }

      it { is_expected.to eq 2 }
    end

    describe 'available_for_expert' do
      subject { described_class.available_for_expert(expert) }

      let(:expert) { create :expert }

      context 'no diagnosis' do
        it { is_expected.to match_array [] }
      end

      context 'one diagnosis' do
        let(:diagnosis) { create :diagnosis }
        let(:need) { create :need, diagnosis: diagnosis }
        let(:expert) { create(:expert) }

        before do
          create :match, need: need, expert: expert, subject: need.subject
        end

        it { is_expected.to match_array [diagnosis] }
      end

      describe 'min_closed_at' do
        subject { described_class.min_closed_at(date_range) }

        let(:date_range) { 12.days.ago..8.days.ago }
        let(:closed_10_days_ago) { create :diagnosis_completed }
        let(:not_closed_10_days_ago) { create :diagnosis_completed }
        let(:closed_20_days_ago) { create :diagnosis_completed }

        before do
          travel_to(10.days.ago) { closed_10_days_ago.reload.matches.first.update(status: :done) }
          travel_to(10.days.ago) { not_closed_10_days_ago.reload.matches.first.update(status: :not_for_me) }
          travel_to(20.days.ago) { closed_20_days_ago.reload.matches.first.update(status: :done) }
        end

        it { is_expected.to match_array [closed_10_days_ago] }
      end
    end
  end
end
