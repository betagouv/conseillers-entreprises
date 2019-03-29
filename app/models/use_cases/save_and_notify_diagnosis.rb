module UseCases
  class SaveAndNotifyDiagnosis
    class << self
      def perform(diagnosis, matches)
        save_experts_skills_selection(diagnosis, matches[:experts_skills])
        save_relays_selection(diagnosis, matches[:needs])
        diagnosis.contacted_persons.each do |person|
          ExpertMailer.delay.notify_company_needs(person, diagnosis)
        end
      end

      private

      def save_experts_skills_selection(diagnosis, experts_skills)
        expert_skill_ids = ids_from_selected_checkboxes(experts_skills)
        if expert_skill_ids.empty?
          return
        end
        UseCases::CreateMatches.perform(diagnosis, expert_skill_ids)
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
