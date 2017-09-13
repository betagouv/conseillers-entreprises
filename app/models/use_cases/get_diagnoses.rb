# frozen_string_literal: true

module UseCases
  class GetDiagnoses
    class << self
      def for_user(user)
        user_diagnoses = Diagnosis.of_user(user).reverse_chronological
        in_progress_associations = [visit: [facility: [:company]]]
        {
          in_progress: user_diagnoses.in_progress.includes(in_progress_associations),
          completed: completed_diagnoses_from_user_diagnoses(user_diagnoses)
        }
      end

      private

      def completed_diagnoses_from_user_diagnoses(diagnoses)
        completed_associations = [
          visit: [:visitee, facility: [:company]], diagnosed_needs: [:selected_assistance_experts]
        ]
        diagnoses = diagnoses.completed.includes(completed_associations)
        diagnoses = diagnosed_need_count_for_diagnoses(diagnoses)
        selected_ae_count_for_diagnoses(diagnoses)
      end

      def diagnosed_need_count_for_diagnoses(diagnoses)
        diagnosed_needs_count_hash = DiagnosedNeed.where(diagnosis: diagnoses).group('diagnosis_id').count
        diagnoses.each { |diagnosis| diagnosis.diagnosed_needs_count = diagnosed_needs_count_hash[diagnosis.id].to_i }
      end

      def selected_ae_count_for_diagnoses(diagnoses)
        selected_ae_count_hash = SelectedAssistanceExpert.of_diagnoses(diagnoses).group('diagnosis_id').count
        diagnoses.each do |diagnosis|
          diagnosis.selected_assistances_experts_count = selected_ae_count_hash[diagnosis.id].to_i
        end
      end
    end
  end
end
