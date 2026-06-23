# == Schema Information
#
# Table name: solicitation_mail_templates
#
#  id         :bigint(8)        not null, primary key
#  body_html  :text             not null
#  email_type :string           not null
#  position   :integer
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
  acts_as_list

  before_validation :slugify_email_type

  validates :title, presence: true, uniqueness: true
  validates :email_type, presence: true, uniqueness: true,
                         format: { with: /\A[a-z0-9_]+\z/ }
  validates :body_html, presence: true
  validate :email_type_is_not_bad_quality

  attr_readonly :email_type

  def to_s = title

  private

  def slugify_email_type
    if new_record? && title.present? && email_type.blank?
      self.email_type = title.parameterize(separator: '_').tr('-', '_').squeeze('_')
    end
  end

  def email_type_is_not_bad_quality
    if email_type == 'bad_quality'
      errors.add(:email_type, :bad_quality)
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[title email_type body_html created_at updated_at id position]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end
end
