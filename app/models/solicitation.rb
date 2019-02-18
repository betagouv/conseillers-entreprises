# == Schema Information
#
# Table name: solicitations
#
#  id           :bigint(8)        not null, primary key
#  description  :string
#  email        :string
#  form_info    :jsonb
#  needs        :jsonb
#  phone_number :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class Solicitation < ApplicationRecord
  ## Associations
  #

  ## Validations
  #
  validates :email, format: { with: PersonConcern::EMAIL_REGEXP }, allow_blank: true

  ## “Through” Associations
  #

  ## Scopes
  #
  scope :of_campaign, -> (campaign) { where("form_info->>'pk_campaign' = ?", campaign) }
  scope :of_alternative, -> (alternative) { where("form_info->>'alternative' = ?", alternative) }

  ## ActiveAdmin helper
  ransacker :alternative do |parent|
    Arel::Nodes::InfixOperation.new('->>', parent.table[:form_info], Arel::Nodes.build_quoted('alternative'))
  end
end
