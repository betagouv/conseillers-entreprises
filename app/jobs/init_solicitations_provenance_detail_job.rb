# Tâche unique, a passer une fois le champs `solicitations.provenance_detail` créé
class InitSolicitationsProvenanceDetailJob < ApplicationJob
  queue_as :low_priority

  def perform
    # Correction des solicitations Entreprendre mal affectées
    Solicitation.where(cooperation_id: [2, nil]).where(provenance_detail: nil).where("solicitations.form_info::json->>'mtm_kwd' LIKE ?", "F%").update_all(cooperation_id: 1)

    Solicitation.where(provenance_detail: nil).where.not(form_info: {}).find_each do |solicitation|
      solicitation.set_provenance_detail
      solicitation.save(validate: false)
    end
  end
end
