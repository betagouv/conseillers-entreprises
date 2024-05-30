# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CompanySatisfaction do
  describe 'scopes' do
    let!(:company_satisfaction_1) { create :company_satisfaction }
    let!(:company_satisfaction_2) { create :company_satisfaction }
    let!(:shared_satisfaction) { create :shared_satisfaction, company_satisfaction: company_satisfaction_1 }

    describe 'shared' do
      subject { described_class.shared }

      it { is_expected.to contain_exactly(company_satisfaction_1) }
    end

    describe 'not_shared' do
      subject { described_class.not_shared }

      it { is_expected.to contain_exactly(company_satisfaction_2) }
    end
  end

  describe 'share' do

    context 'satisfaction with no comment' do
      let(:need) { create :need, matches: [ create(:match, status: :done) ] }
      let!(:company_satisfaction) { create :company_satisfaction, comment: nil, need: need }

      it 'isnt shared' do
        expect(company_satisfaction.share).to be false
      end
    end

    context 'satisfaction ok' do
      let(:expert1) { create :expert_with_users }
      let(:expert2) { create :expert_with_users }
      let(:need) do
        create :need, matches: [
          create(:match, status: :done, expert: expert1),
          create(:match, status: :not_for_me, expert: expert2)
        ]
      end
      let(:company_satisfaction) { create :company_satisfaction, need: need }

      it 'shares to done_users' do
        expect(company_satisfaction.share).to be true
        expect(SharedSatisfaction.all.size).to eq(1)
        expect(SharedSatisfaction.last.expert).to eq(expert1)
      end

      it 'doesnt share twice' do
        expect(SharedSatisfaction.all.size).to eq(0)
        expect { company_satisfaction.share }.to change(SharedSatisfaction.all, :count).by(1)
        expect{ company_satisfaction.share }.not_to change(SharedSatisfaction.all, :count)
      end

      context 'multiple satisfction for an expert' do
        let(:company_satisfaction2) { create :company_satisfaction, need: create(:need, matches: [ create(:match, status: :done, expert: expert1)]) }

        before { company_satisfaction.share }

        it 'can share multiple satisfactions for the same expert' do
          expect(expert1.shared_satisfactions.count).to eq(1)
          expect { company_satisfaction2.share }.to change(expert1.shared_satisfactions, :count).by(1)

        end
      end
    end
  end
end
