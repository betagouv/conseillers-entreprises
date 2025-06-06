module ExpertsHelper
  def expert_card_class(controller, expert)
    if controller.class.module_parent == Reminders
      expert.last_reminder_register.basket
    elsif controller_name == "veille"
      'veille'
    end
  end

  def main_user_absent?(expert)
    user = expert.users.first
    expert.with_one_user? && user.absence_end_at.present? && 
    user.absence_end_at > Time.zone.now && user.absence_start_at < Time.zone.now
  end
end
