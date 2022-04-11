class DeduplicateAntenneManagers < ActiveRecord::Migration[6.1]
  def change
    Antenne.joins(:managers).each do |antenne|
      antenne.managers.each do |manager|
        same_managers = UserRight.where(user: manager, antenne: antenne)
        while same_managers.count > 1 do
          same_managers.last.destroy
        end
      end
    end
    add_index :user_rights, ["user_id", "antenne_id"], unique: true
  end
end
