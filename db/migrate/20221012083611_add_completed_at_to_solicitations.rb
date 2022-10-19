class AddCompletedAtToSolicitations < ActiveRecord::Migration[7.0]
  def change
    add_column :solicitations, :completed_at, :timestamp

    up_only do
      Solicitation.step_complete.each do |solicitation|
        solicitation.update_attribute(:completed_at, solicitation.created_at)
      end
    end
  end
end
