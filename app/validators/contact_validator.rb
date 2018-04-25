class ContactValidator < ActiveModel::Validator
  def validate(contact)
    if contact.email.blank? && contact.phone_number.blank?
      contact.errors.add(:email, :blank)
    end
  end
end
