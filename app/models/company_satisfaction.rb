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

  validates :contacted_by_expert, :useful_exchange, inclusion: { in: [true, false] }
end
