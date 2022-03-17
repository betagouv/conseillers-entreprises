class ContactPolicy < ApplicationPolicy
  def show_needs_history?
    if admin?
      @record.needs.diagnosis_completed.any?
    else
      @user.received_needs.merge(Need.for_emails_and_sirets([@record.email])).any?
    end
  end
end
