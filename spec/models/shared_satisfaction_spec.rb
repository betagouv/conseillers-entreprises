# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SharedSatisfaction do
  describe 'validations' do
    describe 'associations uniqueness' do
      let(:user) { create :user }
      let(:expert) { create :expert, users: [user] }
      let(:company_satisfaction) { create :company_satisfaction }
      let(:shared_satisfaction) { build :shared_satisfaction, company_satisfaction: company_satisfaction, user: user, expert: expert }

      it 'validates unique creation' do
        expect(shared_satisfaction).to be_valid
      end

      context 'with already existing shared_satisfaction' do
        before { create :shared_satisfaction, company_satisfaction: company_satisfaction, user: user, expert: expert }

        it 'doenst validate creation' do
          expect(shared_satisfaction).not_to be_valid
        end
      end
    end
  end

  describe 'scopes' do
    let!(:shared_satisfaction_1) { create :shared_satisfaction, seen_at: Time.zone.now }
    let!(:shared_satisfaction_2) { create :shared_satisfaction, seen_at: nil }

    describe 'seen' do
      subject { described_class.seen }

      it { is_expected.to contain_exactly(shared_satisfaction_1) }
    end

    describe 'unseen' do
      subject { described_class.unseen }

      it { is_expected.to contain_exactly(shared_satisfaction_2) }
    end
  end
end
