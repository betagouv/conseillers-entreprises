module UseCases
  class SaveAndNotifyDiagnosis
    class << self
      def perform(diagnosis, matches)
        relays_selection = matches.delete(:needs)
        save_experts_skills_selection(matches)
        save_relays_selection(diagnosis, relays_selection)
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

      def save_relays_selection(diagnosis, needs)
        need_ids = ids_from_selected_checkboxes(needs)
        if need_ids.empty?
          return
        end
        relays = diagnosis.facility.commune.relays
        relays.each do |relay|
          UseCases::CreateSelectedRelays.perform(relay, need_ids)
        end
      end

      def ids_from_selected_checkboxes(hash)
        if !hash
          return []
        end
        hash.select { |_key, value| value == '1' }.keys.map(&:to_i)
      end
    end
  end
end
