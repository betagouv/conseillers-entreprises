class AddIsSupportToSubject < ActiveRecord::Migration[5.2]
  def change
    add_column :subjects, :is_support, :boolean, default: false
  end
end
