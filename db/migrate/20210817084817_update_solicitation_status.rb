class UpdateSolicitationStatus < ActiveRecord::Migration[6.1]
  def up
    Solicitation.status_in_progress.joins(:feedbacks).update_all(status: :reminded)
  end

  def down
    Solicitation.status_reminded.update_all(status: :in_progress)
  end
end
