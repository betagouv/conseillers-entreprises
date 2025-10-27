class NotNullLogos < ActiveRecord::Migration[7.2]
  def change
    change_column_null(:logos, :logoable_id, false)
    change_column_null(:logos, :logoable_type, false)
    change_column_null(:logos, :name, false)
    change_column_null(:logos, :filename, false)
  end
end
