desc 'Transfer Bizdev'
task transfer_bizdev: :environment do
  require 'highline/import'

  def ask_for_data
    puts "== Procédure de transfert des besoins et territoires lors du départ d'un.e bizdev =="
    leaving_bizdev_email = ask('Email du ou de la bizdev de qui il faut transférer les besoins :')
    @leaving_bizdev = User.find_by!(email: leaving_bizdev_email)
    new_bizdev_email = ask('Email du ou de la bizdev qui récupère les besoins :')
    @new_bizdev = User.find_by!(email: new_bizdev_email)
    transfer_date_string = ask('Seront transférés les besoins déposés après le (date au format YYYY-MM-DD) :')
    @transfer_date = transfer_date_string.to_date
  end

  def prompt_for_confirmation
    puts "Vous vous apprêtez à transférer les besoins et territoires de #{@leaving_bizdev.full_name} vers #{@new_bizdev.full_name} :"
    if !agree("On y va ? (y/n)")
      exit
    end
  end

  def transfer_diagnoses
    @initial_diagnoses_count = @leaving_bizdev.sent_diagnoses.count
    @leaving_bizdev.sent_diagnoses.where(created_at: @transfer_date..).find_each do |diagnosis|
      diagnosis.update!(advisor_id: @new_bizdev.id)
    end
  end

  def transfer_territories
    @initial_territories_count = @leaving_bizdev.supported_territories.count
    @leaving_bizdev.supported_territories.find_each do |territory|
      territory.update!(support_contact_id: @new_bizdev.id)
    end
  end

  def display_results
    puts 'Vérification du transfert :'
    puts "- Territoires transférés : #{@initial_territories_count - @leaving_bizdev.supported_territories.count} (initialement : #{@initial_territories_count})"
    puts "- Analyses transférées : #{@initial_diagnoses_count - @leaving_bizdev.sent_diagnoses.count}  (initialement : #{@initial_diagnoses_count})"
  end

  ask_for_data
  prompt_for_confirmation

  transfer_territories
  transfer_diagnoses
  display_results
end
