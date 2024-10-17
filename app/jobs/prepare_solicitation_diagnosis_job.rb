class PrepareSolicitationDiagnosisJob < ApplicationJob
  def perform(solicitation_id)
    solicitation = Solicitation.find(solicitation_id)
    DiagnosisCreation::PrepareDiagnosis.new(solicitation, nil).call
  end
end
