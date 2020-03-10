# == Schema Information
#
# Table name: institutions
#
#  id             :bigint(8)        not null, primary key
#  antennes_count :integer
#  name           :string
#  partner_token  :string
#  show_icon      :boolean          default(TRUE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_institutions_on_name           (name) UNIQUE
#  index_institutions_on_partner_token  (partner_token)
#

class Institution < ApplicationRecord
  ## Associations
  #
  has_many :antennes, inverse_of: :institution
  has_many :institutions_subjects, inverse_of: :institution

  ## Validations
  #
  validates :name, presence: true, uniqueness: true

  ## Through Associations
  #
  # :institutions_subjects
  has_many :subjects, through: :institutions_subjects, inverse_of: :institutions, dependent: :destroy
  has_many :themes, through: :institutions_subjects, inverse_of: :institutions

  # :antennes
  has_many :experts, through: :antennes, inverse_of: :institution
  has_many :advisors, through: :antennes, inverse_of: :institution
  has_many :sent_diagnoses, through: :antennes, inverse_of: :advisor_institution
  has_many :sent_needs, through: :antennes, inverse_of: :advisor_institution
  has_many :sent_matches, through: :antennes, inverse_of: :advisor_institution

  has_many :received_matches, through: :antennes, inverse_of: :expert_institution
  has_many :received_needs, through: :antennes, inverse_of: :expert_institutions
  has_many :received_diagnoses, through: :antennes, inverse_of: :expert_institutions

  accepts_nested_attributes_for :institutions_subjects, :allow_destroy => true

  def available_subjects
    institutions_subjects
      .ordered_for_interview
      .includes(:theme)
      .group_by { |is| is.theme } # Enumerable#group_by maintains ordering
  end

  ##
  #
  def to_s
    name
  end
end
