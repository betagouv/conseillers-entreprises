class RemoveSolicitationRemindedStatus < ActiveRecord::Migration[6.1]
  def change
    Solicitation.where(status: 3).update_all(status: 'canceled')
  end
end
