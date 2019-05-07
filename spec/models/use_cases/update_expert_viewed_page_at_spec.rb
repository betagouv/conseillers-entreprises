# frozen_string_literal: true

require 'rails_helper'

describe UseCases::UpdateExpertViewedPageAt do
  describe 'perform' do
    subject(:perform_use_case) { described_class.perform diagnosis: diagnosis, expert: expert }

    let(:diagnosis) { create :diagnosis }
    let(:need) { create :need, diagnosis: diagnosis }
    let(:expert) { create :expert }

    let!(:match_with_date) do
      create :match,
        need: need,
        expert_skill: create(:expert_skill, expert: expert),
        expert_viewed_page_at: 1.day.ago
    end

    let!(:match_without_date) do
      create :match,
        need: need,
        expert_skill: create(:expert_skill, expert: expert),
        expert_viewed_page_at: nil
    end

    let!(:match_without_need) do
      create :match,
        expert_skill: create(:expert_skill, expert: expert),
        expert_viewed_page_at: nil
    end

    let!(:match_without_expert_skill) do
      create :match,
        need: need,
        expert_viewed_page_at: nil
    end

    before { perform_use_case }

    it 'updates the match without date' do
      expect(match_without_date.reload.expert_viewed_page_at).not_to be_nil
    end

    it 'does not change others matches' do
      expect(match_with_date.reload.expert_viewed_page_at.to_date).to eq 1.day.ago.to_date
      expect(match_without_need.reload.expert_viewed_page_at).to be_nil
      expect(match_without_expert_skill.reload.expert_viewed_page_at).to be_nil
    end
  end
end
