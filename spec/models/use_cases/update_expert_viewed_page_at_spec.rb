# frozen_string_literal: true

require 'rails_helper'

describe UseCases::UpdateExpertViewedPageAt do
  describe 'perform' do
    subject(:perform_use_case) { described_class.perform diagnosis_id: diagnosis.id, expert_id: expert.id }

    let(:diagnosis) { create :diagnosis }
    let(:diagnosed_need) { create :diagnosed_need, diagnosis: diagnosis }
    let(:expert) { create :expert }
    let(:assistance_expert) { create :assistance_expert, expert: expert }

    let!(:sae_with_date) do
      create :selected_assistance_expert,
             diagnosed_need: diagnosed_need,
             assistance_expert: assistance_expert,
             expert_viewed_page_at: 1.day.ago
    end

    let!(:sae_without_date) do
      create :selected_assistance_expert,
             diagnosed_need: diagnosed_need,
             assistance_expert: assistance_expert,
             expert_viewed_page_at: nil
    end

    let!(:sae_without_diagnosed_need) do
      create :selected_assistance_expert,
             assistance_expert: assistance_expert,
             expert_viewed_page_at: nil
    end

    let!(:sae_without_assistance_expert) do
      create :selected_assistance_expert,
             diagnosed_need: diagnosed_need,
             expert_viewed_page_at: nil
    end

    before { perform_use_case }

    it 'updates the selected assistance expert without date' do
      expect(sae_without_date.reload.expert_viewed_page_at).not_to be_nil
    end

    it 'does not change others selected assistances experts' do
      expect(sae_with_date.reload.expert_viewed_page_at.to_date).to eq 1.day.ago.to_date
      expect(sae_without_diagnosed_need.reload.expert_viewed_page_at).to be_nil
      expect(sae_without_assistance_expert.reload.expert_viewed_page_at).to be_nil
    end
  end
end
