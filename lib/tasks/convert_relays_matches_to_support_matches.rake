task convert_relays_matches_to_support_matches: :environment do
  ActiveRecord::Base.transaction do
    User.relays.each do |relay_user|
      experts = relay_user.experts
      fail unless experts.count == 1
      expert = experts.first

      experts_skills = expert.experts_skills.joins(:skill).where(skills: { subject: Subject.support_subject })
      fail unless experts_skills.count == 1
      support_skill = experts_skills.first

      relay_user.relay_matches.each do |old_match|
        old_match.update_columns(relay_id: nil, experts_skills_id: support_skill.id,
                                 expert_full_name: expert.full_name, skill_title: support_skill.skill.title,
                                 expert_institution_name: expert.antenne.name)
      end
    end
  end
end
