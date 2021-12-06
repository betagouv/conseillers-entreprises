class AddRoleToUsers < ActiveRecord::Migration[6.1]
  def up
    role = %w[advisor admin antenne_manager]
    create_enum 'user_roles', role
    add_column :users, :role, :user_roles, default: 'advisor', null: false

    User.find_each do |user|
      role = if user.is_admin?
        'admin'
      else
        'advisor'
      end
      user.update_columns(role: role)
    end
    remove_column :users, :is_admin
  end

  def down
    add_column :users, :is_admin, :boolean, default: false, null: false

    User.find_each do |user|
      role = user.role_admin?
      user.update_columns(is_admin: role)
    end
    remove_column :users, :role
    drop_enum :user_roles
  end
end
