# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Diagnosis, type: :model do
  it do
    is_expected.to have_many :needs
    is_expected.to belong_to :advisor
    is_expected.to belong_to :facility
    is_expected.to validate_presence_of :advisor
    is_expected.to validate_presence_of :facility
    is_expected.to validate_inclusion_of(:step).in_array(Diagnosis::AUTHORIZED_STEPS)
  end

  describe 'custom validations' do
    describe 'last_step_has_matches' do
      subject(:diagnosis) { build :diagnosis, step: Diagnosis::LAST_STEP }

      context 'no matches' do
        it { is_expected.not_to be_valid }
      end

      context 'with matches' do
        before do
          diagnosis.needs << build(:need, matches: [build(:match)])
        end

        it { is_expected.to be_valid }
      end
    end

    describe 'step_4_has_visit_attributes' do
      subject(:diagnosis) { build :diagnosis, step: 4, visitee: visitee, happened_on: happened_on }

      context 'missing attributes' do
        let(:visitee) { nil }
        let(:happened_on) { nil }

        before { diagnosis.validate }

        it { is_expected.not_to be_valid }
        it { expect(diagnosis.errors.details.keys).to match_array [:visitee, :happened_on] }
      end

      context 'with matches' do
        let(:visitee) { build :contact_with_email }
        let(:happened_on) { Date.today }

        it { is_expected.to be_valid }
      end
    end
  end

  describe 'scopes' do
    describe 'in progress' do
      subject { described_class.in_progress.count }

      it do
        create :diagnosis_completed
        create :diagnosis, step: 2
        create :diagnosis, step: 4

        is_expected.to eq 2
      end
    end

    describe 'completed' do
      subject { described_class.completed.count }

      it do
        create :diagnosis_completed
        create :diagnosis_completed
        create :diagnosis, step: 4

        is_expected.to eq 2
      end
    end

    describe 'available_for_expert' do
      subject { described_class.available_for_expert(expert) }

      let(:expert) { create :expert }

      context 'no diagnosis' do
        it { is_expected.to eq [] }
      end

      context 'one diagnosis' do
        let(:diagnosis) { create :diagnosis }
        let(:need) { create :need, diagnosis: diagnosis }
        let(:expert) { create(:expert) }

        before do
          create :match, need: need, expert: expert, subject: need.subject
        end

        it { is_expected.to eq [diagnosis] }
      end
    end
  end

  describe 'match_and_notify!' do
    subject(:match_and_notify) { diagnosis.match_and_notify!(matches) }

    let(:diagnosis) { create :diagnosis, step: 4 }
    let(:need) { create :need, diagnosis: diagnosis }
    let(:expert) { create :expert }
    let(:experts_subjects) { create :expert_subject, expert: expert, subject: need.subject }
    let(:matches) { { need.id => [experts_subjects.id] } }

    context 'selected experts_subjects for related needs' do
      it do
        expect{ match_and_notify }.to change(Match, :count).by(1)
        expect(Match.last.expert).to eq expert
        expect(Match.last.subject).to eq need.subject
        expect(diagnosis.step).to eq Diagnosis::LAST_STEP
      end
    end

    context 'no selected expert_subjects' do
      let(:matches) { { need.id => [] } }

      it { expect{ match_and_notify }.to raise_error ActiveRecord::RecordInvalid }
    end

    context 'unrelated need' do
      let(:need) { create :need }

      it { expect{ match_and_notify }.to raise_error ActiveRecord::RecordNotFound }
    end
  end
end
