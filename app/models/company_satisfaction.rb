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
  has_one :diagnosis, through: :need, inverse_of: :company_satisfactions
  has_one :solicitation, through: :diagnosis, inverse_of: :company_satisfactions
  has_one :landing, through: :solicitation, inverse_of: :solicitations
  has_one :landing_subject, through: :solicitation, inverse_of: :solicitations
  has_one :subject, through: :need, inverse_of: :needs
  has_one :theme, through: :need, inverse_of: :needs
  has_many :matches, through: :need, inverse_of: :need
  has_many :facility_regions, through: :need, inverse_of: :needs
  has_one :facility, through: :need, inverse_of: :needs

  # Satisfaction pour les MER avec aide proposée
  has_many :done_matches, -> { status_done }, class_name: 'Match', through: :need, inverse_of: :need, source: :matches
  has_many :done_experts, class_name: 'Expert', through: :done_matches, source: :expert
  has_many :done_antennes, class_name: 'Antenne', through: :done_experts, source: :antenne
  has_many :done_institutions, class_name: 'Institution', through: :done_antennes, source: :institution

  validates :contacted_by_expert, :useful_exchange, inclusion: { in: [true, false] }

  scope :solicitation_mtm_campaign_cont, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_cont(query))
  }

  scope :solicitation_mtm_campaign_eq, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_eq(query))
  }

  scope :solicitation_mtm_campaign_start, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_start(query))
  }

  scope :solicitation_mtm_campaign_end, -> (query) {
    joins(:solicitation).merge(Solicitation.mtm_campaign_end(query))
  }

  def self.ransackable_scopes(auth_object = nil)
    %w[solicitation_mtm_campaign_cont solicitation_mtm_campaign_eq solicitation_mtm_campaign_start solicitation_mtm_campaign_end]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["comment", "contacted_by_expert", "created_at", "id", "id_value", "need_id", "updated_at", "useful_exchange"]
  end

  def self.ransackable_associations(auth_object = nil)
    [
      "done_antennes", "done_experts", "done_institutions", "done_matches", "facility_regions", "landing",
      "landing_subject", "matches", "need", "diagnosis", "solicitation", "subject", "theme", "facility"
    ]
  end
end
