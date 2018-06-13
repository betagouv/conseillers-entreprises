# frozen_string_literal: true

module UseCases
  class GetDiagnoses
    class << self
      def for_user(user)
        user_diagnoses = Diagnosis.only_active.of_user(user).reverse_chronological
        in_progress_associations = [visit: [facility: [:company]]]
        {
          in_progress: user_diagnoses.in_progress.includes(in_progress_associations),
          completed: completed_diagnoses_from_user_diagnoses(user_diagnoses)
        }
      end

      def for_siret(siret)
        associations = [diagnosed_needs: :matches, visit: :advisor]
        diagnoses = Diagnosis.only_active.completed.includes(associations).of_siret(siret)
        diagnoses = UseCases::EnrichDiagnoses.with_diagnosed_needs_count(diagnoses)
        UseCases::EnrichDiagnoses.with_selected_assistances_experts_count(diagnoses)
      end

      private

      def completed_diagnoses_from_user_diagnoses(diagnoses)
        completed_associations = [
          visit: [:visitee, facility: [:company]], diagnosed_needs: [:matches]
        ]
        diagnoses = diagnoses.completed.includes(completed_associations)
        diagnoses = UseCases::EnrichDiagnoses.with_diagnosed_needs_count(diagnoses)
        diagnoses = UseCases::EnrichDiagnoses.with_selected_assistances_experts_count(diagnoses)
        UseCases::EnrichDiagnoses.with_solved_needs_count(diagnoses)
      end
    end
  end
end
