# == Schema Information
#
# Table name: institutions
#
#  id             :bigint(8)        not null, primary key
#  antennes_count :integer
#  name           :string
#  show_icon      :boolean          default(TRUE)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class Institution < ApplicationRecord
  ## Associations
  #
  has_many :antennes, inverse_of: :institution

  ## Validations
  #
  validates :name, presence: true

  ## Through Associations
  #
  # :antennes
  has_many :experts, through: :antennes, inverse_of: :institution
  has_many :advisors, through: :antennes, inverse_of: :institution
  has_many :sent_diagnoses, through: :antennes, inverse_of: :advisor_institution
  has_many :sent_needs, through: :antennes, inverse_of: :advisor_institution
  has_many :sent_matches, through: :antennes, inverse_of: :advisor_institution

  has_many :received_matches, through: :antennes, inverse_of: :expert_institution
  has_many :received_needs, through: :antennes, inverse_of: :expert_institutions
  has_many :received_diagnoses, through: :antennes, inverse_of: :expert_institutions

  ##
  #
  def to_s
    name
  end
end
