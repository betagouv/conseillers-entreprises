class CreateAutomaticDiagnosisJob < ApplicationJob
  def perform(solicitation_id)
    solicitation = Solicitation.find(solicitation_id)
    DiagnosisCreation::CreateAutomaticDiagnosis.new(solicitation).call
  end
end
