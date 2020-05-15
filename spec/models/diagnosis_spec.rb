# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Diagnosis, type: :model do
  it do
    is_expected.to have_many :needs
    is_expected.to belong_to :advisor
    is_expected.to belong_to :facility
  end

  describe 'custom validations' do
    describe 'last_step_has_matches' do
      subject(:diagnosis) { build :diagnosis, step: described_class.steps[:completed] }

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
      subject(:diagnosis) { build :diagnosis, step: :matches, visitee: visitee, happened_on: happened_on }

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
        create :diagnosis, step: :needs
        create :diagnosis, step: :matches

        is_expected.to eq 2
      end
    end

    describe 'completed' do
      subject { described_class.completed.count }

      it do
        create :diagnosis_completed
        create :diagnosis_completed
        create :diagnosis, step: :matches

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
end
