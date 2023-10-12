class DeleteDiagnosesWithManySolicitations < ActiveRecord::Migration[7.0]
  def change
    Solicitation.where(created_at: (Time.now - 2.years)..Time.now).find_each do |solicitation|
      diagnoses = Diagnosis.joins(:solicitation).where(solicitations: { id: solicitation.id })
      not_completed = diagnoses.where(step: :completed)

      if diagnoses.many? && # plusieurs analyses
        not_completed.present? && # dont au moins une complète
          diagnoses.where.not(step: :completed).present? && # et une incomplète
        diagnoses.map { |d| d.subjects.ids }.flatten.uniq.count == 1 # sur le même sujet
        not_completed.destroy_all # on supprime les incomplètes
      end
    end
  end
end
