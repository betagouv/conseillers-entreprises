module PersonConcern
  extend ActiveSupport::Concern

  included do
    validates :full_name, :role, presence: true
    validates :email, format: { with: Devise.email_regexp }, allow_blank: true
  end

  def to_s
    full_name
  end

  def email_with_display_name
    if email.nil?
      nil
    elsif full_name.nil?
      email
    else
      "\"#{full_name}\" <#{email}>"
    end
  end

  def normalize_values!
    normalize_name
    normalize_phone_number
    normalize_email
    normalize_role
    save!
  end

  def normalize_name
    self.full_name = self.full_name.squish.titleize
  end

  def normalize_email
    self.email = self.email.strip.downcase
  end

  def normalize_phone_number
    number = self.phone_number.gsub(/[^0-9]/,'')
    if number.length == 10
      number = number.gsub(/(.{2})(?=.)/, '\1 \2')
      self.phone_number = number
    end
  end

  def normalize_role
    self.role = self.role.squish.titleize
  end
end
