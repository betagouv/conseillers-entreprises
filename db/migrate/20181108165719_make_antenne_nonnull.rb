class MakeAntenneNonnull < ActiveRecord::Migration[5.2]
  def up
    change_column_null :antennes, :institution_id, false
    change_column_null :experts, :antenne_id, false
  end

  def down
    change_column_null :antennes, :institution_id, true
    change_column_null :experts, :antenne_id, true
  end
end
