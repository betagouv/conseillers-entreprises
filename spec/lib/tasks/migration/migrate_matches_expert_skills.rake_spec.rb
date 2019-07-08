require 'rails_helper'

describe 'rake matches_expert_skills:migrate', type: :task do
  it 'runs gracefully with no matches' do
    expect { task.execute }.not_to raise_error
  end

  context 'with matches' do
    let(:expert_skill) { create :expert_skill, expert: create(:expert), skill: create(:skill) }
    let(:match_to_migrate) { create(:match, :legacy, expert_skill: expert_skill) }
    let(:already_migrated_match) { create :match, expert: create(:expert), skill: create(:skill), experts_skills_id: expert_skill.id }

    before do
      match_to_migrate
      already_migrated_match
    end

    subject(:migrate_matches) do
      task.execute
      match_to_migrate.reload
      already_migrated_match.reload
    end

    it 'migrates Matches without expert or skill' do
      migrate_matches
      expect(match_to_migrate.expert).to eq expert_skill.expert
      expect(match_to_migrate.skill).to eq expert_skill.skill
    end

    it 'doesn’t migrate already migrated Matches' do
      expect{ migrate_matches }.not_to change { already_migrated_match.slice(:expert, :skill) }
    end
  end
end
