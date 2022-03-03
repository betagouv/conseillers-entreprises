desc 'Create national antenne managers'
task create_national_managers: :environment do
  response = ''
  while response == "y" || response == '' do
    puts 'Entrez la ligne csv d’un responsable'
    managers_row = $stdin.gets.chomp.split(',')
    managers_row.map(&:strip!)
    # [Institutions,Antennes nationales,Responsables nationaux,Émail,Téléphone]
    institution = Institution.find_by(name: managers_row[0])
    antenne = Antenne.find_or_create_by!(name: managers_row[1], institution: institution)
    antenne.update(nationale: true)
    user = User.find_by(email: managers_row[3])
    if user.present?
      user.update(antenne: antenne, full_name: managers_row[2], phone_number: managers_row[4],
                  job: 'Responsable national', role: 'antenne_manager')
    else
      User.create!(email: managers_row[3], antenne: antenne, full_name: managers_row[2],
                   phone_number: managers_row[4], job: 'Responsable national', role: :antenne_manager)
    end
    puts 'Créer un nouveau responsable ? Y/n'
    response = $stdin.gets.chomp
  end
end
