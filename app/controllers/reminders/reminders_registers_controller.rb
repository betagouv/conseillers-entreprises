module Reminders
  class RemindersRegistersController < BaseController
    def update
      reminders_register = RemindersRegister.find(params[:id])
      reminders_register.update(processed: true)
      redirect_back_or_to(inputs_reminders_experts_path)
    end
  end
end
