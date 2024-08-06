module ExpertsHelper
  def expert_card_class(controller, expert)
    if controller.class.module_parent == Reminders
      expert.last_reminder_register.basket
    elsif controller_name == "veille"
      'veille'
    end
  end
end
