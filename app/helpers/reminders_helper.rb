module RemindersHelper
  def build_reminders_card_footer(action, need)
    #  si c'est dans a relancer, a rappeler, pas pour moi, affichage d'une action
    #  si c'est en cours d'abandon afficher le mail de derniere chance
    #  si "pas pour moi" envoyer l'email d'echec
    html = ""
    html << email_button(action, need) if with_email.include? action
    html << action_button(action, need) if with_action.include? action
    html
  end

  private

  def with_email
    %i[last_chance archive not_for_me]
  end

  def with_last_chance_email
    %i[last_chance]
  end

  def with_abandoned_email
    %i[archive not_for_me]
  end

  def with_action
    %i[poke archive not_for_me last_chance]
  end

  def with_archive_action
    %i[not_for_me]
  end

  def action_button(action, need)
    # Afficher l'action archiver dans le panier "refusé"
    action = :archive if with_archive_action.include? action
    link_to t(action, scope: 'reminders.needs.scopes.mark_done'), polymorphic_path([action, :reminders_action], { id: need.id }),
            method: :post, class: "fr-btn #{action == :archive ? 'btn-red' : 'btn-green'}"
  end

  def email_button(action, need)
    button = if with_last_chance_email.include? action
      form_builder(send_last_chance_email_reminders_need_path(need), t('reminders.send_last_chance_email'), need)
    elsif with_abandoned_email.include? action
      if need.abandoned_email_sent
        p_tag_builder(t('reminders.abandoned_need_email_sent'))
      else
        form_builder(send_abandoned_email_reminders_need_path(need), t('reminders.send_abandoned_need_email'), need)
      end
    end
    tag.div(button, id: "reminder-email-#{need.id}",)
  end

  def p_tag_builder(text)
    tag.p(text, class: 'fr-btn fr-btn--secondary fr-fi-checkbox-circle-line fr-btn--icon-left fr-btn-green fr-mr-2v')
  end

  def form_builder(path, text, need, form_options = {})
    form_with(model: need, url: path, method: :post, **form_options) do |f|
      f.submit text, class: 'fr-btn fr-btn--secondary fr-mr-2v'
    end.html_safe
  end
end
