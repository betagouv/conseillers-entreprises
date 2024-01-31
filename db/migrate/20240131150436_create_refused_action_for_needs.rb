class CreateRefusedActionForNeeds < ActiveRecord::Migration[7.0]
  def change
    # On prend les besoins refusés avec l'action :abandoned
    # Si la date de creation de l'action abandonner moin la date de creation du besoin est inferieur à 45 jours
    # et que le statut à ce moment là était refusé on enlève l'action :abandoned
    # dans tous les cas on ajoute l'action refusé pour vider le panier dans les relances

    needs = Need.reminders_to(:refused).with_action(:abandon)

    count = 0
    needs.each do |need|
      action = need.reminders_actions.find_by(category: 'abandon')
      fourty_five_days_in_seconds = 45 * 24 * 60 * 60
      if (action.created_at - need.created_at) <= fourty_five_days_in_seconds && computed_status(need, action.created_at) == :not_for_me
        count += 1
        need.reminders_actions.where(category: 'abandon').destroy_all
      end
      need.reminders_actions.create(category: 'refused')
    end
    puts 'DEBUG: CreateRefusedActionForNeeds: count = ' + count.to_s
  end

  # reprise de la méthode dans du model Need mais pour avoir le statut avant la date de l'action :abandon
  def computed_status(need, date)
    matches_status = need.matches.where(closed_at: ...date).pluck(:status).map(&:to_sym)

    # no matches yet
    if need.matches.empty? || !need.diagnosis.step_completed?
      :diagnosis_not_complete

      # at least one match done:
    elsif matches_status.include?(:done)
      :done
    elsif matches_status.include?(:done_no_help)
      :done_no_help
    elsif matches_status.include?(:done_not_reachable)
      :done_not_reachable

      # at least one match not closed
    elsif matches_status.include?(:taking_care)
      :taking_care
    elsif matches_status.include?(:quo)
      :quo
    else
      :not_for_me
    end
  end
end
