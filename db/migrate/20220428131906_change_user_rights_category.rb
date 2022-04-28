class ChangeUserRightsCategory < ActiveRecord::Migration[7.0]
  def up
    change_column_null :user_rights, :right, true
    add_column :user_rights, :category, :integer

    # user_right sans effets et pretant a confusion
    UserRight.where(right: 'advisor').destroy_all

    UserRight.where(right: 'manager').update_all(category: 0)
    UserRight.where(right: 'admin').update_all(category: 1)

    change_column_null :user_rights, :category, false
    add_index :user_rights, [:user_id, :antenne_id, :category], unique: true
    remove_column :user_rights, :right
    drop_enum :rights
  end

  def down
    create_enum "rights", %w[advisor admin manager]
    add_column :user_rights, :right, :rights
    change_column_null :user_rights, :category, true

    UserRight.where(category: 0).update_all(right: 'manager')
    UserRight.where(category: 1).update_all(right: 'admin')

    remove_column :user_rights, :category
    change_column_null :user_rights, :right, false
    add_index :user_rights, [:user_id, :antenne_id, :right], unique: true
  end
end
