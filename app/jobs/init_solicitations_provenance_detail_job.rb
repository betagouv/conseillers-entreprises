# Tâche unique, a passer une fois le champs `solicitations.provenance_detail` créé
class InitSolicitationsProvenanceDetailJob < ApplicationJob
  queue_as :low_priority

  def perform
    Solicitation.where(provenance_detail: nil).where.not(form_info: {}).find_each do |solicitation|
      solicitation.set_provenance_detail
      solicitation.save(validate: false)
    end
  end
end
