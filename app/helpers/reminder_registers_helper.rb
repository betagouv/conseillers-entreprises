module ReminderRegistersHelper
  def with_reminder_action?(action)
    action == :inputs || action == :outputs || action == :expired_needs
  end

  def get_reminder_register(expert, action)
    case action
    when :inputs
      return expert.input_register
    when :expired_needs
      return expert.expired_need_register
    when :outputs
      return expert.output_register
    end
  end
end
