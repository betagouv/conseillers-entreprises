class AddFacilityToVisit < ActiveRecord::Migration[5.1]
  def change
    add_reference :visits, :facility, foreign_key: true
  end
end
