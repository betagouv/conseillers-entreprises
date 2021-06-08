desc 'Deploy region'
task deploy_region: :environment do
  require 'highline/import'

  data = {
    code_region: 2,
    region_name: 'Martinique',
    deployed_at: "2021-06-10".to_datetime,
    referent_email: 'adeline.latron@beta.gouv.fr',
    institution_slug: 'collectivite_de_martinique'
  }

  def prompt_for_confirmation(data)
    puts "Vous vous apprêtez à déployer la région '#{data[:region_name]}' avec les données suivantes :"
    data.each {|key, value| puts "- #{key}: #{value}\n" }
    if !agree("On y va ? (y/n)")
      exit
    end
  end

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
  if data[:institution_slug].present?
    institution = Institution.where(slug: data[:institution_slug]).first_or_initialize
    institution.update!(code_region: data[:code_region])
  end

  puts "Région déployée."
end
