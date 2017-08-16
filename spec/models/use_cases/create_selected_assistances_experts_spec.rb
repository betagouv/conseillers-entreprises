# frozen_string_literal: true

require 'rails_helper'

describe UseCases::CreateSelectedAssistancesExperts do
  describe 'perform' do
    let(:diagnosis) { create :diagnosis }
    let(:question) { create :question }
    let(:assistance) { create :assistance, question: question }
    let(:assistance_expert) { create :assistance_expert, assistance: assistance }
    let!(:diagnosed_need) { create :diagnosed_need, question: question, diagnosis: diagnosis }

    let(:assistance_expert_ids) { [assistance_expert.id] }

    context 'no selected need' do
      before { described_class.perform(diagnosis, assistance_expert_ids) }

      it 'creates a diagnosis linked to the right visit' do
        expect(SelectedAssistanceExpert.all.count).to eq 1
        expect(SelectedAssistanceExpert.first.diagnosed_need).to eq diagnosed_need
        expect(SelectedAssistanceExpert.first.assistance_expert).to eq assistance_expert
      end

      it 'stores the right data' do
        expect(SelectedAssistanceExpert.first.expert_full_name).to eq assistance_expert.expert.full_name
        expect(SelectedAssistanceExpert.first.expert_institution_name).to eq assistance_expert.expert.institution.name
        expect(SelectedAssistanceExpert.first.assistance_title).to eq assistance_expert.assistance.title
      end
    end
  end
end
