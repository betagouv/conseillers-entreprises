desc 'Transfer Bizdev'
task transfer_bizdev: :environment do
  require 'highline/import'

  def ask_for_data
    leaving_bizdev_email = ask('Email du ou de la bizdev de qui il faut transférer les dossiers :')
    @leaving_bizdev = User.find_by!(email: leaving_bizdev_email)
    new_bizdev_email = ask('Email du ou de la bizdev qui récupère les dossiers :')
    @new_bizdev = User.find_by!(email: new_bizdev_email)
  end

  def prompt_for_confirmation
    puts "Vous vous apprêtez à transférer les dossiers de #{@leaving_bizdev.full_name} vers #{@new_bizdev.full_name} :"
    if !agree("On y va ? (y/n)")
      exit
    end
  end

  def transfer_feedbacks
    @leaving_bizdev.feedbacks.find_each do |feedback|
      feedback.update!(user_id: @new_bizdev.id)
    end
  end

  def transfer_diagnoses
    @leaving_bizdev.sent_diagnoses.find_each do |diagnosis|
      diagnosis.update!(advisor_id: @new_bizdev.id)
    end
  end

  def transfer_territories
    @leaving_bizdev.supported_territories.find_each do |territory|
      territory.update!(support_contact_id: @new_bizdev.id)
    end
  end

  def display_results
    puts 'Vérification du transfert :'
    puts "- Territoires encore affectés au dev partant : #{@leaving_bizdev.supported_territories.count}"
    puts "- Analyses encore affectées au dev partant : #{@leaving_bizdev.sent_diagnoses.count}"
    puts "- Commentaires encore affectés au dev partant : #{@leaving_bizdev.feedbacks.count}"
  end

  ask_for_data
  prompt_for_confirmation

  transfer_territories
  transfer_diagnoses
  transfer_feedbacks
  display_results
end
