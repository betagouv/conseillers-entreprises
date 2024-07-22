module PersonConcern
  extend ActiveSupport::Concern

  included do
    ## Validation
    #
    validates :full_name, presence: true
    validates :email, format: { with: Devise.email_regexp }, allow_blank: true

    ## Data sanitization
    #
    before_validation :normalize_values
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
    normalize_job
  end

  def normalize_values!
    normalize_values
    save!
  end

  def normalize_name
    return unless self.full_name

    self.full_name = self.full_name.squish.gsub(/\b([a-z])/) { $1.capitalize }
  end

  def normalize_email
    return unless self.email

    self.email.gsub!(/[,;]/,".")
    self.email = ActiveSupport::Inflector.transliterate(self.email.squish.downcase)
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

  def normalize_job
    return unless self.class.method_defined?(:job) && self.job.present?

    self.job = self.job.squish.titleize
  end

  def user_expert_shared_attributes
    shared_attributes = %w[email full_name phone_number antenne_id]
    self.attributes.slice(*shared_attributes)
  end
end
