task update_users_emails: :environment do
  puts 'Mise à jour des emails utilisateurs'
  puts '---'
  puts "Format du CSV : séparateur de colonne : ',', séparateur de ligne : ';'"
  puts 'CSV au format text :'
  string = $stdin.gets.chomp

  csv = CSV.parse(string, col_sep: ',', row_sep: ';')

  csv.each do |row|
    puts '---'
    old_email = row.first
    new_email = row.last
    user = User.find_by(email: old_email)
    expert = Expert.find_by(email: old_email)

    puts "Utilisateur : #{user.to_s} /  #{user.antenne.to_s}" if user.present?
    puts "Referent : #{user.to_s} /  #{user.antenne.to_s}" if expert.present?

    if user.present? || expert.present?
      puts "remplacer '#{old_email}' par '#{new_email}' ? Y/n"
    else
      puts "Aucun utilisateur ni referent n'a été trouvé avec l’email #{old_email}"
      next
    end

    response = $stdin.gets.chomp
    if response.empty? || response.casecmp('y').zero?
      user.update_columns(email: new_email) if user.present?
      expert.update_columns(email: new_email) if expert.present?
      puts "Ok"
    else
      puts "Mise à jour annulée"
    end
  end
  puts "Mise à jour terminée"
end
