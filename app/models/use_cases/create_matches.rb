module UseCases
  class CreateMatches
    class << self
      def perform(diagnosis, expert_skill_ids)
        experts_skills = experts_skills_for_diagnosis(diagnosis.id, expert_skill_ids)
        experts_skills.each do |expert_skill|
          diagnosed_need = expert_skill.skill.subject.diagnosed_needs.first
          if !diagnosed_need
            next
          end
          expert = expert_skill.expert
          skill = expert_skill.skill
          Match.create expert_skill: expert_skill, diagnosed_need: diagnosed_need,
                       expert_full_name: expert.full_name, skill_title: skill.title,
                       expert_institution_name: expert.antenne.name
        end
      end

      private

      def experts_skills_for_diagnosis(diagnosis_id, expert_skill_ids)
        associations = [
          :expert, :skill, expert: :antenne_institution, skill: [
            :subject, subject: [:diagnosed_needs, diagnosed_needs: :diagnosis]
          ]
        ]
        condition = { skills: { subjects: { diagnosed_needs: { diagnoses: { id: diagnosis_id } } } } }
        ExpertSkill.joins(associations).includes(associations).where(condition).where(id: expert_skill_ids)
      end
    end
  end
end
