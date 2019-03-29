# frozen_string_literal: true

require 'rails_helper'

describe UseCases::CreateSelectedRelays do
  describe 'perform' do
    let(:relay) { create :relay }
    let(:diagnosed_needs) { create_list :diagnosed_need, 1 }
    let(:diagnosed_need_ids) { diagnosed_needs.map(&:id) }

    let(:expert_skill_ids) { [expert_skill.id] }

    context 'one selected diagnosed need' do
      before { described_class.perform(relay, diagnosed_need_ids) }

      it do
        expect(Match.all.count).to eq 1
        expect(Match.first.diagnosed_need).to eq diagnosed_needs.first
        expect(Match.first.expert_skill).to be_nil
        expect(Match.first.relay).to eq relay
        expect(Match.first.expert_full_name).to eq relay.user.full_name
        expect(Match.first.expert_institution_name).to eq relay.user.institution
        expect(Match.first.skill_title).to be_nil
      end
    end
  end
end
