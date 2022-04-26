class FixUserRightsIndex < ActiveRecord::Migration[6.1]
  def change
    up_only do
      # correction des managers sans managed_antennes
      UserRight.right_manager.where(antenne_id: nil).each do |ur|
        ur.antenne = ur.user.antenne
        ur.save
      end
    end

    remove_index :user_rights, ["user_id", "antenne_id"], unique: true
    add_index :user_rights, ["user_id", "antenne_id", "right"], unique: true
  end
end