# frozen_string_literal: true

module UseCases
  class GetDiagnoses
    class << self
      def for_user(user)
        in_progress_associations = [visit: [facility: [:company]]]
        completed_associations = [
          visit: [:visitee, facility: [:company]], diagnosed_needs: [:selected_assistance_experts]
        ]
        user_diagnoses = Diagnosis.of_user(user).reverse_chronological
        {
          in_progress: user_diagnoses.in_progress.includes(in_progress_associations),
          completed: user_diagnoses.completed.includes(completed_associations)
        }
      end
    end
  end
end
