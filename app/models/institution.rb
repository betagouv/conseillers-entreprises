# == Schema Information
#
# Table name: institutions
#
#  id                      :bigint(8)        not null, primary key
#  antennes_count          :integer
#  name                    :string
#  qualified_for_artisanry :boolean          default(TRUE), not null
#  qualified_for_commerce  :boolean          default(TRUE), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
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
  has_many :experts, through: :antennes, inverse_of: :antenne_institution
  has_many :advisors, through: :antennes, inverse_of: :antenne_institution
  has_many :sent_diagnoses, through: :antennes, inverse_of: :advisor_institution
  has_many :sent_diagnosed_needs, through: :antennes, inverse_of: :advisor_institution
  has_many :sent_matches, through: :antennes, inverse_of: :advisor_institution

  has_many :received_matches, through: :antennes, inverse_of: :expert_institution
  has_many :received_diagnosed_needs, through: :antennes, inverse_of: :expert_institutions
  has_many :received_diagnoses, through: :antennes, inverse_of: :expert_institutions

  ## Scopes
  #
  scope :of_naf_code, (lambda do |naf_code|
    naf_code_for_artisan?(naf_code) ? qualified_for_artisanry : qualified_for_commerce
  end)
  scope :qualified_for_artisanry, (-> { where(qualified_for_artisanry: true) })
  scope :qualified_for_commerce, (-> { where(qualified_for_commerce: true) })

  ##
  #
  def to_s
    name
  end

  ##
  #
  def self.naf_code_for_artisan?(naf_code)
    %w[
      1011Z 1012Z 1013A 1013B 1020Z 1031Z 1032Z 1039A 1039B 1041A 1041B 1042Z 1051A 1051B 1051C 1051D 1052Z 1061A 1061B
      1062Z 1071A 1071A 1071C 1071C 1071D 1072Z 1073Z 1081Z 1082Z 1083Z 1084Z 1086Z 1089Z 1091Z 1092Z 1101Z 1101Z 1102A
      1103Z 1104Z 1105Z 1106Z 1107A 1107B 4722Z 4722Z 4722Z 4722Z 4722Z 4723Z 4781Z 4781Z 5610C
    ].include? naf_code
  end
end
