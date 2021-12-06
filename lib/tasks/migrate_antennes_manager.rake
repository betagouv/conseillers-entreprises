desc 'Migrate antenne manager fields to real users'
task migrate_antennes_managers: :environment do
  managers_without_users = {}
  managers_count = 0
  Antenne.find_each do |antenne|
    next if antenne.manager_email.blank?

    manager = User.find_by(email: antenne.manager_email.downcase)
    if manager.nil?
      managers_without_users[antenne.name] = {
        nom: antenne.manager_full_name,
                                            email: antenne.manager_email,
                                            telephone: antenne.manager_phone
      }
    else
      next if manager.role_antenne_manager?
      manager.update(role: 'antenne_manager')
      managers_count += 1
    end
  end

  puts "#{managers_count} responsables ajoutés"
  puts "#{managers_without_users.keys.count} responsables non trouvés"
  puts "liste des responsables sans utilisateur :"
  puts managers_without_users
end
