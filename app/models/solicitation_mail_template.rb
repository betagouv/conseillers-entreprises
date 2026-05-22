# == Schema Information
#
# Table name: solicitation_mail_templates
#
#  id         :bigint(8)        not null, primary key
#  body_html  :text             not null
#  email_type :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_solicitation_mail_templates_on_email_type  (email_type) UNIQUE
#
class SolicitationMailTemplate < ApplicationRecord
  validates :email_type, presence: true, uniqueness: true,
                         inclusion: { in: Solicitation::GENERIC_EMAILS_TYPES.flatten.without(:bad_quality).map(&:to_s) }
  validates :body_html, presence: true

  def to_s
    I18n.t("solicitations.solicitation_actions.emails.#{email_type}", default: email_type)
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[email_type body_html created_at updated_at id]
  end
end
