class RemoveManagersFields < ActiveRecord::Migration[6.1]
  def change
    up_only do
      managers_without_users = {}
      managers_created_count = 0
      Antenne.not_deleted.where.not(manager_email: nil).where.not(manager_email: "").without_managers.find_each do |antenne|
        p antenne
        manager = User.find_or_initialize_by(email: antenne.manager_email.strip.downcase)
        byebug
        manager.update(
          antenne: antenne,
          role: 'antenne_manager',
          job: I18n.t('attributes.manager'),
          full_name: antenne.manager_full_name,
          phone_number: antenne.manager_phone
        ) if manager.new_record?

        if manager.nil?
          managers_without_users[antenne.name] = {
            nom: antenne.manager_full_name,
            email: antenne.manager_email,
            telephone: antenne.manager_phone
          }
        else
          manager.invite!(User.find_by(email: 'claire.zuliani@beta.gouv.fr')) unless manager.invitation_sent_at
          managers_created_count += 1
        end
      end

      puts "#{managers_created_count} responsables créés et invités"
      puts "#{managers_without_users.keys.count} responsables non trouvés"
      puts "liste des responsables restant sans utilisateur :"
      puts managers_without_users
    end
    remove_column :antennes, :manager_full_name, :string
    remove_column :antennes, :manager_email, :string
    remove_column :antennes, :manager_phone, :string
  end
end
