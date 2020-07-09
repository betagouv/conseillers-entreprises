class RemoveShowIconToAntenne < ActiveRecord::Migration[6.0]
  def change
    remove_column :antennes, :show_icon, :boolean
  end
end
