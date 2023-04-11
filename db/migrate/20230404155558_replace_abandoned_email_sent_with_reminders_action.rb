class ReplaceAbandonedEmailSentWithRemindersAction < ActiveRecord::Migration[7.0]
  def change
    up_only do
      # Remplacement de abandoned_email_sent par reminders_action(:abandon) - étape 1
      Need.where(abandoned_email_sent: true).find_each do |need|
        need.reminders_actions.create(category: 'abandon')
      end
      # Désarchivage des besoins refusés
      Need.status_not_for_me.archived(true).update_all(archived_at: nil)
      Match.status_not_for_me.archived(true).joins(:need).merge(Need.status_not_for_me).update_all(archived_at: nil)
    end
  end
end
