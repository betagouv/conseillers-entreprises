namespace :matches_expert_skills do
  desc "Migrate Match#expert_skill to Match#expert and Match#skill"
  task migrate: :environment do
    matches_to_migrate = Match
      .where.not(experts_skills_id: nil)
      .where(expert_id: nil)
      .where(skill_id: nil)

    matches_to_migrate.find_each do |match|
      expert_skill = ExpertSkill.find(match.experts_skills_id)
      match.update_columns(
        expert_id: expert_skill.expert.id,
        skill_id: expert_skill.skill.id
      )
    end
  end
end
