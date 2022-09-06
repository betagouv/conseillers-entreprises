module RemindersHelper
  def build_reminders_card_footer(action, need)
    #  si c'est dans a relancer, a rappeler, abandonné, pas pour moi, affichage d'une action
    #  si c'est en cours d'abandon afficher le mail de derniere chance
    #  si c'est abandonné et pas pour moi envoyer l'email d'echec
    html = ""
    html << email_button(action, need)
    html << action_button(action, need) if with_action.include? action
    html
  end

  private

  def with_last_chance_email
    %i[will_be_abandoned]
  end

  def with_abandoned_email
    %i[archive not_for_me]
  end

  def with_reminder_email
    %i[poke recall]
  end

  def with_action
    %i[poke recall archive not_for_me]
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
      if need.last_chance_email_sent?
        p_tag_builder(t('reminders.last_chance_email_sent'))
      else
        form_builder(send_last_chance_email_reminders_need_path(need), t('reminders.send_last_chance_email'), need)
      end
    elsif with_abandoned_email.include? action
      if need.abandoned_email_sent
        p_tag_builder(t('reminders.abandoned_need_email_sent'))
      else
        form_builder(send_abandoned_email_reminders_need_path(need), t('reminders.send_abandoned_need_email'), need)
      end
    elsif with_reminder_email.include? action
      form_builder(send_reminder_email_reminders_need_path(need), t('reminders.send_reminder_email_email'), need)
    end
    tag.div(button, id: "reminder-email-#{need.id}",)
  end

  def p_tag_builder(text)
    tag.p(text, class: 'fr-btn fr-btn--secondary fr-fi-checkbox-circle-line fr-btn--icon-left fr-btn-green fr-mr-2v')
  end

  def form_builder(path, text, need)
    form_with model: need, url: path, method: :post do |f|
      f.submit text, class: 'fr-btn fr-btn--secondary fr-mr-2v'
    end.html_safe
  end
end
