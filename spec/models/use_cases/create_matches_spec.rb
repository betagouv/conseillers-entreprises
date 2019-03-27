# frozen_string_literal: true

require 'rails_helper'

describe UseCases::CreateMatches do
  describe 'perform' do
    let(:diagnosis) { create :diagnosis }
    let(:question) { create :question }
    let(:skill) { create :skill, question: question }
    let(:expert_skill) { create :expert_skill, skill: skill }
    let!(:diagnosed_need) { create :diagnosed_need, question: question, diagnosis: diagnosis }

    let(:expert_skill_ids) { [expert_skill.id] }

    context 'one match' do
      before { described_class.perform(diagnosis, expert_skill_ids) }

      it do
        expect(Match.first.diagnosed_need).to eq diagnosed_need
        expect(Match.first.expert_skill).to eq expert_skill
        expect(Match.first.relay).to be_nil
        expect(Match.first.skill_title).to eq expert_skill.skill.title
        expect(Match.first.expert_full_name).to eq expert_skill.expert.full_name
        expect(Match.first.expert_institution_name).to eq expert_skill.expert.antenne.name
      end
    end
  end
end
