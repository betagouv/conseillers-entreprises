require 'rails_helper'

RSpec.describe Activity do
  describe Match do
    describe '#with_activity' do
      let!(:match_with_no_action) { create :match, status: :quo }
      let!(:match_active_a_long_time_ago) { create :match, status: :not_for_me, updated_at: 100.days.ago }
      let!(:match_recently_active) { create :match, status: :not_for_me, updated_at: 10.days.ago }

      it 'returns recently active matches' do
        expect(described_class.with_activity(50.days.ago..)).to contain_exactly(match_recently_active)
      end
    end
  end

  describe Expert do
    describe 'Expert#with_activity / #without_activity' do
      let!(:inactive_expert) do
        create :expert, received_matches: [
          build(:match, status: :quo),
          build(:match, status: :not_for_me, updated_at: 100.days.ago)
        ]
      end
      let!(:active_expert) { create :expert, received_matches: [build(:match, status: :not_for_me, updated_at: 10.days.ago)] }

      it 'returns the relevant experts' do
        expect(described_class.with_activity(50.days.ago..)).to contain_exactly(active_expert)
        expect(described_class.without_activity(50.days.ago..)).to contain_exactly(inactive_expert)
      end
    end
  end

  describe User do
    describe 'User#with_activity/#without_activity' do
      let(:inactive_expert) do
        build :expert, received_matches: [
          build(:match, status: :quo),
          build(:match, status: :not_for_me, updated_at: 100.days.ago)
        ]
      end
      let(:active_expert) { build :expert, received_matches: [build(:match, status: :not_for_me, updated_at: 10.days.ago)] }
      let!(:active_user_1) { create :user, experts: [active_expert] }
      let!(:active_user_2) { create :user, experts: [active_expert, inactive_expert] }
      let!(:inactive_user) { create :user, experts: [inactive_expert] }
      let!(:inactive_manager) { create :user, :manager, experts: [inactive_expert] }

      it 'returns the relevant users' do
        expect(described_class.with_activity(50.days.ago..)).to contain_exactly(active_user_1, active_user_2, inactive_manager)
        expect(described_class.without_activity(50.days.ago..)).to include(inactive_user)
        expect(described_class.without_activity(50.days.ago..)).not_to include(active_user_1, active_user_2, inactive_manager)
      end
    end
  end
end
