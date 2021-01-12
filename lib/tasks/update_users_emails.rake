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
    if user.nil?
      puts "Aucun utilisateur trouvé avec l’email #{old_email}"
      next
    end
    puts "Utilisateur : #{user.to_s} /  #{user.antenne.to_s}"
    puts "remplacer '#{old_email}' par '#{new_email}' ? Y/n"
    response = $stdin.gets.chomp
    if response.empty? || response.casecmp('y').zero?
      if user.update_columns(email: new_email)
        puts "Ok"
      else
        puts "Erreur"
      end
    else
      puts "Mise à jour annulée"
    end
  end
  puts "Mise à jour terminée"
end
