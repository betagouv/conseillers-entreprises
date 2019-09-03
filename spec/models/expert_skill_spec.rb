# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExpertSkill, type: :model do
  describe 'validations' do
    it do
      is_expected.to belong_to :skill
      is_expected.to belong_to :expert
    end
  end

  describe 'scopes' do
    describe 'relevant_for' do
      subject(:experts_skills) { ExpertSkill.relevant_for(need) }

      let(:need) do
        create :need,
               subject: create(:subject),
               diagnosis: create(:diagnosis, facility: create(:facility, commune: create(:commune)))
      end

      let(:relevant_skill) { create(:skill, subject: need.subject) }
      let(:unrelated_skill) { create :skill, subject: create(:subject) }

      let(:local_expert1) { create :expert, communes: [need.facility.commune] }
      let(:local_expert2) { create :expert, communes: [need.facility.commune] }
      let(:faraway_expert) { create :expert, communes: [create(:commune)] }

      let(:local_relevant_ae) { create :expert_skill, expert: local_expert1, skill: relevant_skill }

      before do
        # local_unrelated
        create :expert_skill, expert: local_expert2, skill: unrelated_skill
        # faraway
        create :expert_skill, expert: faraway_expert, skill: relevant_skill
      end

      it { is_expected.to eq [local_relevant_ae] }
    end
  end
end
