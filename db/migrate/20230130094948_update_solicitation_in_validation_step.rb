class UpdateSolicitationInValidationStep < ActiveRecord::Migration[7.0]
  def change
    Solicitation.where(status: 6).update_all(status: 2)
  end
end
