class RenameDiagnosedNeedToNeed < ActiveRecord::Migration[5.2]
  def change
    rename_table :diagnosed_needs, :needs
    rename_column :matches, :diagnosed_need_id, :need_id
  end
end
