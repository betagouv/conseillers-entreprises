# frozen_string_literal: true

require 'rails_helper'

describe UseCases::CreateSelectedTerritoryUsers do
  describe 'perform' do
    let(:territory_user) { create :territory_user }
    let(:diagnosed_needs) { create_list :diagnosed_need, 1 }
    let(:diagnosed_need_ids) { diagnosed_needs.map(&:id) }

    let(:assistance_expert_ids) { [assistance_expert.id] }

    context 'one selected diagnosed need' do
      before { described_class.perform(territory_user, diagnosed_need_ids) }

      it do
        expect(SelectedAssistanceExpert.all.count).to eq 1
        expect(SelectedAssistanceExpert.first.diagnosed_need).to eq diagnosed_needs.first
        expect(SelectedAssistanceExpert.first.assistance_expert).to be_nil
        expect(SelectedAssistanceExpert.first.territory_user).to eq territory_user
        expect(SelectedAssistanceExpert.first.expert_full_name).to eq territory_user.user.full_name
        expect(SelectedAssistanceExpert.first.expert_institution_name).to eq territory_user.user.institution
        expect(SelectedAssistanceExpert.first.assistance_title).to be_nil
      end
    end
  end
end
