class AddNameToExpertsDeleted < ActiveRecord::Migration[7.0]
  def change
    Expert.where.not(deleted_at: nil)
      .where(full_name: nil)
      .update_all(full_name: I18n.t('deleted_account.full_name'))
  end
end
