desc 'Deploy region'
task deploy_region: :environment do
  require 'highline/import'

  def ask_for_data
    data = {}
    puts "Saisissez les informations de la région (code région, nom, email du référent, date de déploiement, institution liée)"
    data[:code_region] = ask('Code région ?')
    data[:region_name] = ask('Nom de la région ?')
    data[:deployed_at] = ask('Date de déploiement ? (format YYYY-MM-DD)').to_date
    data[:referent_email] = ask('Email du référent PDE ?')
    data[:institution_name] = ask('Nom de l\'institution régionale ? (optionnel)') { |q| q.default = nil }
    return data
  end

  def prompt_for_confirmation(data)
    puts "Vous vous apprêtez à déployer la région suivante :"
    data.each { |key, value| puts "- #{key}: #{value}\n" }
    if !agree("On y va ? (y/n)")
      exit
    end
  end

  data = ask_for_data

  prompt_for_confirmation(data)

  ## Set referent
  ref = User.find_by!(email: data[:referent_email])

  ## Create or update territory
  region = Territory.where(code_region: data[:code_region]).first_or_initialize
  region.update!(
    name: data[:region_name],
    bassin_emploi: false,
    deployed_at: data[:deployed_at],
    support_contact_id: ref.id
  )

  # Create or update institution
  if data[:institution_name].present?
    institution = Institution.where(name: data[:institution_name]).first_or_initialize
    institution.slug = data[:institution_name].parameterize.underscore if institution.slug.blank?
    institution.update!(
      code_region: data[:code_region]
    )
  end

  puts "Région déployée."
end
