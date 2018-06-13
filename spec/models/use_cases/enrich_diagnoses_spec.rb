# frozen_string_literal: true

require 'rails_helper'

describe UseCases::EnrichDiagnoses do
  describe 'with_diagnosed_needs_count' do
    subject(:diagnoses_with_count) { described_class.with_diagnosed_needs_count diagnoses }

    let(:diagnoses) { [diagnosis] }
    let(:diagnosis) { create :diagnosis }

    context 'no diagnosed need' do
      it { expect(diagnoses_with_count.first.diagnosed_needs_count).to eq 0 }
    end

    context '2 diagnosed needs' do
      before { create_list :diagnosed_need, 2, diagnosis: diagnosis }

      it { expect(diagnoses_with_count.first.diagnosed_needs_count).to eq 2 }
    end

    context '2 diagnosis and 3 needs' do
      let(:diagnoses) { [diagnosis, other_diagnosis] }
      let(:other_diagnosis) { create :diagnosis }

      before do
        create_list :diagnosed_need, 2, diagnosis: diagnosis
        create_list :diagnosed_need, 1, diagnosis: other_diagnosis
      end

      it do
        expect(diagnoses_with_count.first.diagnosed_needs_count).to eq 2
        expect(diagnoses_with_count.last.diagnosed_needs_count).to eq 1
      end
    end
  end

  describe 'with_matches_count' do
    subject(:diagnoses_with_count) { described_class.with_matches_count diagnoses }

    let(:diagnoses) { [diagnosis] }
    let(:diagnosis) { create :diagnosis }
    let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }

    context 'no selected assistance expert' do
      it { expect(diagnoses_with_count.first.matches_count).to eq 0 }
    end

    context '2 selected assistances experts' do
      before { create_list :match, 2, diagnosed_need: diagnosed_need }

      it { expect(diagnoses_with_count.first.matches_count).to eq 2 }
    end

    context '2 diagnosis and 3 selected assistances experts' do
      let(:diagnoses) { [diagnosis, other_diagnosis] }
      let(:other_diagnosis) { create :diagnosis }
      let(:other_diagnosed_need) { create :diagnosed_need, diagnosis: other_diagnosis }

      before do
        create_list :match, 2, diagnosed_need: diagnosed_need
        create_list :match, 1, diagnosed_need: other_diagnosed_need
      end

      it do
        expect(diagnoses_with_count.first.matches_count).to eq 2
        expect(diagnoses_with_count.last.matches_count).to eq 1
      end
    end
  end

  describe 'with_solved_needs_count' do
    subject(:diagnoses_with_count) { described_class.with_solved_needs_count diagnoses }

    let(:diagnoses) { [diagnosis] }
    let(:diagnosis) { create :diagnosis }

    context 'no diagnosed need' do
      it { expect(diagnoses_with_count.first.solved_needs_count).to eq 0 }
    end

    context '3 match with one done' do
      let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }

      before do
        create :match, diagnosed_need: diagnosed_need, status: :taking_care
        create :match, diagnosed_need: diagnosed_need, status: :done
        create :match, diagnosed_need: diagnosed_need, status: :not_for_me
      end

      it { expect(diagnoses_with_count.first.solved_needs_count).to eq 1 }
    end

    context '3 match, all done' do
      let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }

      before do
        create :match, diagnosed_need: diagnosed_need, status: :done
        create :match, diagnosed_need: diagnosed_need, status: :done
        create :match, diagnosed_need: diagnosed_need, status: :done
      end

      it { expect(diagnoses_with_count.first.solved_needs_count).to eq 1 }
    end

    context '3 diagnosed_needs, 5 match' do
      let(:diagnosed_need1) { create :diagnosed_need, diagnosis: diagnosis }
      let(:diagnosed_need2) { create :diagnosed_need, diagnosis: diagnosis }
      let(:diagnosed_need3) { create :diagnosed_need, diagnosis: diagnosis }

      before do
        create :match, diagnosed_need: diagnosed_need1, status: :done
        create :match, diagnosed_need: diagnosed_need2, status: :taking_care
        create :match, diagnosed_need: diagnosed_need2, status: :done
        create :match, diagnosed_need: diagnosed_need2, status: :done
        create :match, diagnosed_need: diagnosed_need3, status: :taking_care
      end

      it { expect(diagnoses_with_count.first.solved_needs_count).to eq 2 }
    end
  end
end
