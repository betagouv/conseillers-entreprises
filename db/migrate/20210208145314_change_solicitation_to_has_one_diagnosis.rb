class ChangeSolicitationToHasOneDiagnosis < ActiveRecord::Migration[6.0]
  def change
    up_only do
      solicitations = Solicitation.joins(:diagnoses).group('solicitations.id').having('count(solicitation_id) > 1')
      solicitations.map do |solicitation|
        steps = solicitation.diagnoses.pluck(:step)
        if (steps.include?('not_started') || steps.include?('needs') || steps.include?('visit') || steps.include?('matches')) && steps.include?('completed')
          # Supprime les analyses non complétées des sollicitation qui on au moins une analyse de complète
          solicitation.diagnoses.where(step: ['not_started', 'needs', 'visit', 'matches']).destroy_all
        end
        solicitation.diagnoses.each_with_index do |diagnosis, index|
          # associe une seule analyse pour chaque sollicitation
          next if index == 0
          new_solicitation = solicitation.dup
          new_solicitation.created_at = solicitation.created_at
          new_solicitation.save!(validate: false)
          Diagnosis.find(diagnosis.id).update(solicitation: new_solicitation)
        end
      end
    end
  end
end
