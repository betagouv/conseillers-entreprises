# == Schema Information
#
# Table name: company_satisfactions
#
#  id                  :bigint(8)        not null, primary key
#  comment             :text
#  contacted_by_expert :boolean
#  useful_exchange     :boolean
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  need_id             :bigint(8)        not null
#
# Indexes
#
#  index_company_satisfactions_on_need_id  (need_id)
#
# Foreign Keys
#
#  fk_rails_...  (need_id => needs.id)
#
class CompanySatisfaction < ApplicationRecord
  belongs_to :need, inverse_of: :company_satisfaction
  has_one :solicitation, through: :need, inverse_of: :diagnosis
  has_one :landing, through: :solicitation, inverse_of: :solicitations
  has_one :landing_subject, through: :solicitation, inverse_of: :solicitations
  has_one :subject, through: :need, inverse_of: :needs
  has_many :matches, through: :need, inverse_of: :need

  validates :contacted_by_expert, :useful_exchange, inclusion: { in: [true, false] }
end
