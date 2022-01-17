desc 'Create antenne manager fields to real users'
task create_managers: :environment do
  managers_without_users = {}
  managers_created_count = 0
  Antenne.where.not(manager_email: nil).without_managers.find_each do |antenne|
    manager = User.find_or_initialize_by(email: antenne.manager_email.strip.downcase)
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
      manager.invite!(User.find_by(email: 'claire.zuliani@beta.gouv.fr'))
      managers_created_count += 1
    end
  end

  puts "#{managers_created_count} responsables créés et invités"
  puts "#{managers_without_users.keys.count} responsables non trouvés"
  puts "liste des responsables restant sans utilisateur :"
  puts managers_without_users
end
