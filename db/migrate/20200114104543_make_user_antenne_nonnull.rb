class MakeUserAntenneNonnull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :users, :antenne_id, false
  end
end
