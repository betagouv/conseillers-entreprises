class AddContentToDiagnosedNeed < ActiveRecord::Migration[5.1]
  def change
    add_column :diagnosed_needs, :content, :text
  end
end
