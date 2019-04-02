module UseCases
  class SaveAndNotifyDiagnosis
    class << self
      def perform(diagnosis, matches)
        save_experts_skills_selection(matches)
        diagnosis.contacted_persons.each do |person|
          ExpertMailer.delay.notify_company_needs(person, diagnosis)
        end
      end

      private

      def save_experts_skills_selection(matches)
        matches.each do |need_id, expert_skills_selection|
          need = Need.find(need_id)
          selected_experts_skills = expert_skills_selection.select{ |_,v| v == "1" }.keys.map{ |id| ExpertSkill.find(id) }
          selected_experts_skills.each do |expert_skill|
            expert = expert_skill.expert
            skill = expert_skill.skill
            Match.create(expert_skill: expert_skill, need: need,
                         expert_full_name: expert.full_name, skill_title: skill.title,
                         expert_institution_name: expert.antenne.name)
          end
        end
      end
    end
  end
end
