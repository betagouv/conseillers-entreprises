class ContactPolicy < ApplicationPolicy
  def needs_historic?
    if admin?
      @record.needs.diagnosis_completed.any?
    else
      @user.received_needs.merge(Need.for_emails(@record.email)).any?
    end
  end
end
