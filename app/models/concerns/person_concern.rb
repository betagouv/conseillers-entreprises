module PersonConcern
  extend ActiveSupport::Concern

  included do
    ## Validation
    #
    validates :full_name, :role, presence: true
    validates :email, format: { with: Devise.email_regexp }, allow_blank: true
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

  def normalize_values!
    normalize_name
    normalize_phone_number
    normalize_email
    normalize_role
    save!
  end

  def normalize_name
    self.full_name = titleize_if_all_same_case(self.full_name.squish)
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
    self.role = titleize_if_all_same_case(self.role.squish)
  end

  private

  def titleize_if_all_same_case(str)
    # Titleize if the input is all lowercase or all uppercase,
    # leave it intact otherwise.
    if str.in? [str.downcase, str.upcase]
      str.titleize
    else
      str
    end
  end
end
