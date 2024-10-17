class CreateAutomaticDiagnosisJob < ApplicationJob
  def perform(solicitation_id)
    solicitation = Solicitation.find(solicitation_id)
    DiagnosisCreation::CreateAutomaticDiagnosis.new(solicitation, nil).call
  end
end
