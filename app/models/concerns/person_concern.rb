module PersonConcern
  extend ActiveSupport::Concern

  included do
    ## Validation
    #
    validates :full_name, presence: true
    validates :email, format: { with: Devise.email_regexp }, allow_blank: true

    ## Data sanitization
    #
    before_validation :normalize_values, on: :create
  end

  ## Display helpers
  #
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

  ## Data sanitization
  #
  def normalize_values
    normalize_name
    normalize_email
    normalize_phone_number
    normalize_role
  end

  def normalize_values!
    normalize_values
    save!
  end

  def normalize_name
    return unless self.full_name

    self.full_name = self.full_name.squish.titleize
  end

  def normalize_email
    return unless self.email

    self.email = self.email.strip.downcase
  end

  def normalize_phone_number
    return unless self.phone_number

    number = self.phone_number.gsub(/[^0-9]/,'')
    number.insert(0, '0') if number.length == 9 && number.first != '0'
    if number.length == 10
      number = number.gsub(/(.{2})(?=.)/, '\1 \2')
      self.phone_number = number
    end
  end

  def normalize_role
    return unless self.role

    self.role = self.role.squish.titleize
  end
end
