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

    context 'one selected assistance expert' do
      before { described_class.perform(diagnosis, assistance_expert_ids) }

      it do
        expect(SelectedAssistanceExpert.first.diagnosed_need).to eq diagnosed_need
        expect(SelectedAssistanceExpert.first.assistance_expert).to eq assistance_expert
        expect(SelectedAssistanceExpert.first.relay).to be_nil
        expect(SelectedAssistanceExpert.first.assistance_title).to eq assistance_expert.assistance.title
        expect(SelectedAssistanceExpert.first.expert_full_name).to eq assistance_expert.expert.full_name
        expect(SelectedAssistanceExpert.first.expert_institution_name).to eq assistance_expert.expert.institution.name
      end
    end
  end
end
