class CreateUserRight < ActiveRecord::Migration[6.1]
  def up
    rights = %w[advisor admin manager]
    create_enum 'rights', rights

    create_table :user_rights do |t|
      t.references :antenne, null: true, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.enum "right", default: "advisor", null: false, enum_type: "rights"
      t.timestamps
    end

    User.where(role: 'antenne_manager').each do |user|
      user.user_rights.create(right: 'manager', antenne: user.antenne)
    end

    User.where(role: 'admin').each do |user|
      user.user_rights.create(right: 'admin')
    end

    remove_column :users, :role
    drop_enum :user_roles
  end

  def down
    role = %w[advisor admin antenne_manager]
    create_enum 'user_roles', role
    add_column :users, :role, :user_roles, default: 'advisor', null: false

    User.joins(:user_rights).where(user_rights: { role: 'admin' }).distinct.each do |user|
      user.update_columns(role: 'admin')
    end

    User.joins(:user_rights).where(user_rights: { role: 'manager' }).distinct.each do |user|
      user.update_columns(role: 'antenne_manager')
    end

    drop_table :user_rights
    drop_enum :rights
  end
end
