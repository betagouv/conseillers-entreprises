# frozen_string_literal: true

require 'rails_helper'

describe UseCases::CreateSelectedRelays do
  describe 'perform' do
    let(:relay) { create :relay }
    let(:diagnosed_needs) { create_list :diagnosed_need, 1 }
    let(:diagnosed_need_ids) { diagnosed_needs.map(&:id) }

    let(:assistance_expert_ids) { [assistance_expert.id] }

    context 'one selected diagnosed need' do
      before { described_class.perform(relay, diagnosed_need_ids) }

      it do
        expect(SelectedAssistanceExpert.all.count).to eq 1
        expect(SelectedAssistanceExpert.first.diagnosed_need).to eq diagnosed_needs.first
        expect(SelectedAssistanceExpert.first.assistance_expert).to be_nil
        expect(SelectedAssistanceExpert.first.relay).to eq relay
        expect(SelectedAssistanceExpert.first.expert_full_name).to eq relay.user.full_name
        expect(SelectedAssistanceExpert.first.expert_institution_name).to eq relay.user.institution
        expect(SelectedAssistanceExpert.first.assistance_title).to be_nil
      end
    end
  end
end
