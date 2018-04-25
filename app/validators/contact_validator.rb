class ContactValidator < ActiveModel::Validator
  def validate(contact)
    contact.errors.add(:email, :blank) if contact.email.blank? && contact.phone_number.blank?
  end
end
