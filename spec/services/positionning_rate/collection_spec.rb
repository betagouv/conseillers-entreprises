# frozen_string_literal: true

require 'rails_helper'
describe PositionningRate::Collection do
  let!(:expert_critical_rate_01) { create :expert }
  let!(:expert_critical_rate_02) { create :expert }
  let!(:expert_worrying_rate_01) { create :expert }
  let!(:expert_worrying_rate_02) { create :expert }
  let!(:expert_pending_rate) { create :expert }
  let!(:expert_no_rate) { create :expert }
  let!(:new_positionning_rate_collection) { described_class.new(Expert.all) }

  before do
    expert_critical_rate_01.received_matches << [
      create(:match, created_at: 8.days.ago)
    ]
    expert_critical_rate_02.received_matches << [
      create(:match, created_at: 8.days.ago),
      create(:match, created_at: 8.days.ago),
      create(:match, created_at: 10.days.ago),
      create(:match, created_at: 8.days.ago, status: 'taking_care')
    ]
    expert_worrying_rate_01.received_matches << [
      create(:match, created_at: 8.days.ago),
      create(:match, created_at: 8.days.ago, status: 'taking_care')
    ]
    expert_worrying_rate_02.received_matches << [
      create(:match, created_at: 8.days.ago),
      create(:match, created_at: 61.days.ago),
      create(:match, created_at: 61.days.ago),
      create(:match, created_at: 8.days.ago, status: 'taking_care')
    ]
    expert_pending_rate.received_matches << [
      create(:match, created_at: 8.days.ago),
      create(:match, created_at: 8.days.ago, status: 'taking_care'),
      create(:match, created_at: 8.days.ago, status: 'taking_care')
    ]
  end

  describe 'critical_rate' do
    subject(:result_experts) { new_positionning_rate_collection.critical_rate.distinct }

    it do
      expect(result_experts).to match_array([expert_critical_rate_02, expert_critical_rate_01])
      # Test de PositionningRate::Member ici, pour ne pas instancier ailleurs la même floppée d'objets
      expect(PositionningRate::Member.new(expert_critical_rate_02).critical_rate?).to be true
      expect(PositionningRate::Member.new(expert_worrying_rate_01).critical_rate?).to be false
    end
  end

  describe 'worrying_rate' do
    subject(:result_experts) { new_positionning_rate_collection.worrying_rate.distinct }

    it do
      expect(result_experts).to match_array([expert_worrying_rate_02, expert_worrying_rate_01])
      expect(PositionningRate::Member.new(expert_worrying_rate_01).worrying_rate?).to be true
      expect(PositionningRate::Member.new(expert_pending_rate).worrying_rate?).to be false
    end
  end

  describe 'pending_rate' do
    subject(:result_experts) { new_positionning_rate_collection.pending_rate.distinct }

    it do
      expect(result_experts).to match_array([expert_pending_rate])
      expect(PositionningRate::Member.new(expert_pending_rate).pending_rate?).to be true
      expect(PositionningRate::Member.new(expert_critical_rate_02).pending_rate?).to be false
    end
  end
end
