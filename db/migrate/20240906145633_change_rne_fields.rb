class ChangeRneFields < ActiveRecord::Migration[7.0]
  def change
    add_column :facilities, :nature_activites, :string, array: true, default: []
    add_column :facilities, :nafa_codes, :string, array: true, default: []

    # remove_column :companies, :activite_liberale, :boolean, default: false
    # remove_column :companies, :independant, :boolean, default: false
    # remove_column :companies, :inscrit_rcs, :boolean, default: false
    # remove_column :companies, :inscrit_rm, :boolean, default: false
  end
end
