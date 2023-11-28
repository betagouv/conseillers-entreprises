class PrepareSolicitationDiagnosisJob < ApplicationJob
  def perform(solicitation_id)
    solicitation = Solicitation.find(solicitation_id)
    solicitation.prepare_diagnosis(nil)
  end
end
