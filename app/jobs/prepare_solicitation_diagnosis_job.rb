class PrepareSolicitationDiagnosisJob < ApplicationJob
  def perform(solicitation_id)
    solicitation = Solicitation.find(solicitation_id)
    CreateDiagnosis::PrepareDiagnosis.new(solicitation, nil).call
  end
end
