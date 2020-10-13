class AddSolicitationInstitution < ActiveRecord::Migration[6.0]
  def change
    add_reference :solicitations, :institution, foreign_key: true, null: true
    up_only do
      Solicitation.joins({ landing: :institution }).each do |solicitation|
        solicitation.update_column(:institution_id, solicitation.landing.institution_id)
      end
    end
  end
end
