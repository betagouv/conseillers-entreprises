# == Schema Information
#
# Table name: antennes
#
#  id             :bigint(8)        not null, primary key
#  deleted_at     :datetime
#  name           :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  institution_id :bigint(8)        not null
#
# Indexes
#
#  index_antennes_on_deleted_at               (deleted_at)
#  index_antennes_on_institution_id           (institution_id)
#  index_antennes_on_name_and_institution_id  (name,institution_id) UNIQUE
#  index_antennes_on_updated_at               (updated_at)
#
# Foreign Keys
#
#  fk_rails_...  (institution_id => institutions.id)
#

class Antenne < ApplicationRecord
  include SoftDeletable
  ## Associations
  #
  has_and_belongs_to_many :communes, inverse_of: :antennes
  include ManyCommunes
  include InvolvementConcern

  belongs_to :institution, inverse_of: :antennes

  has_many :experts, inverse_of: :antenne
  has_many :advisors, class_name: 'User', inverse_of: :antenne

  ## Hooks and Validations
  #
  auto_strip_attributes :name
  validates :name, presence: true, uniqueness: { scope: :institution_id }
  validates :institution, presence: true

  ## “Through” Associations
  #
  # :communes
  has_many :territories, -> { distinct.bassins_emploi }, through: :communes, inverse_of: :antennes
  has_many :regions, -> { distinct.regions }, through: :communes, inverse_of: :antennes

  # :advisors
  has_many :sent_diagnoses, through: :advisors, inverse_of: :advisor_antenne
  has_many :sent_needs, through: :advisors, inverse_of: :advisor_antenne
  has_many :sent_matches, through: :advisors, inverse_of: :advisor_antenne

  # :experts
  has_many :received_matches, through: :experts, inverse_of: :expert_antenne
  has_many :received_needs, through: :experts, inverse_of: :expert_antennes
  has_many :received_diagnoses, through: :experts, inverse_of: :expert_antennes

  ##
  #
  scope :without_communes, -> { left_outer_joins(:communes).where(communes: { id: nil }) }

  scope :by_antenne_and_institution_names, -> (antennes_and_institutions_names) do
    tuples_array = antennes_and_institutions_names
    # AFAICT, expanding the tuples_array as a single `IN (?)` parameter is unsupported in ActiveRecord
    # Instead, build as many `IN ((?),(?),…)` as needed, and splat the array.
    joins(:institution)
      .where("(antennes.name, institutions.name) IN (#{(['(?)'] * tuples_array.size).join(', ')})", *tuples_array)
  end

  ##
  #
  def to_s
    name
  end

  def support_user
    return if regions.many? || regions.blank?
    User.find(Antenne.find(id).regions.first.support_contact_id)
  end

  def user_support_email
    if support_user.present?
      "#{support_user.full_name} - #{I18n.t('app_name')} <#{support_user.email}>"
    else
      "#{I18n.t('app_name')} <#{ENV['APPLICATION_EMAIL']}>"
    end
  end
end
