# frozen_string_literal: true

module UseCases
  class EnrichDiagnoses
    class << self
      def with_diagnosed_needs_count(diagnoses)
        diagnosed_needs_count_hash = DiagnosedNeed.of_diagnosis(diagnoses).group('diagnosis_id').count
        diagnoses.each { |diagnosis| diagnosis.diagnosed_needs_count = diagnosed_needs_count_hash[diagnosis.id].to_i }
      end

      def with_selected_assistances_experts_count(diagnoses)
        selected_ae_count_hash = SelectedAssistanceExpert.of_diagnoses(diagnoses).group('diagnosis_id').count
        diagnoses.each do |diagnosis|
          diagnosis.selected_assistances_experts_count = selected_ae_count_hash[diagnosis.id].to_i
        end
      end

      def with_solved_needs_count(diagnoses)
        dn_hash = DiagnosedNeed.of_diagnosis(diagnoses).with_at_least_one_expert_done.group('diagnosis_id').count
        diagnoses.each do |diagnosis|
          diagnosis.solved_needs_count = dn_hash[diagnosis.id].to_i
        end
      end
    end
  end
end
