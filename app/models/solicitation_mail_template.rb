# == Schema Information
#
# Table name: solicitation_mail_templates
#
#  id         :bigint(8)        not null, primary key
#  body_html  :text             not null
#  email_type :string           not null
#  title      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_solicitation_mail_templates_on_email_type  (email_type) UNIQUE
#  index_solicitation_mail_templates_on_title       (title) UNIQUE
#
class SolicitationMailTemplate < ApplicationRecord
  before_validation :slugify_email_type

  validates :title, presence: true, uniqueness: true
  validates :email_type, presence: true, uniqueness: true,
                         inclusion: { in: Solicitation::GENERIC_EMAILS_TYPES.flatten.without(:bad_quality).map(&:to_s) }
  validates :body_html, presence: true

  def to_s
    I18n.t("solicitations.solicitation_actions.emails.#{email_type}", default: email_type)
    title
  end

  private

  def slugify_email_type
    if new_record? && title.present? && email_type.blank?
      self.email_type = title.parameterize(separator: '_').gsub('-', '_').gsub(/_+/, '_')
    end
  end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[email_type body_html created_at updated_at id]
  end
end
