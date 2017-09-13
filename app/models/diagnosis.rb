# frozen_string_literal: true

class Diagnosis < ApplicationRecord
  AUTHORIZED_STEPS = [1, 2, 3, 4, 5].freeze
  acts_as_paranoid

  attr_accessor :diagnosed_needs_count, :selected_assistances_experts_count

  belongs_to :visit

  has_many :diagnosed_needs
  accepts_nested_attributes_for :diagnosed_needs

  validates :visit, presence: true
  validates :step, inclusion: { in: AUTHORIZED_STEPS }

  scope :of_siret, (->(siret) { joins(:visit).merge(Visit.of_siret(siret)) })
  scope :of_user, (->(user) { joins(:visit).where(visits: { advisor: user }) })
  scope :reverse_chronological, (-> { order(created_at: :desc) })
  scope :in_progress, (-> { where(step: [1..4]) })
  scope :completed, (-> { where(step: 5) })

  def creation_date_localized
    I18n.l(created_at.to_date)
  end

  class << self
    def enrich_with_diagnosed_needs_count(diagnoses)
      diagnosed_needs_count_hash = DiagnosedNeed.where(diagnosis: diagnoses).group('diagnosis_id').count
      diagnoses.each { |diagnosis| diagnosis.diagnosed_needs_count = diagnosed_needs_count_hash[diagnosis.id].to_i }
    end

    def enrich_with_selected_assistances_experts_count(diagnoses)
      selected_ae_count_hash = SelectedAssistanceExpert.of_diagnoses(diagnoses).group('diagnosis_id').count
      diagnoses.each do |diagnosis|
        diagnosis.selected_assistances_experts_count = selected_ae_count_hash[diagnosis.id].to_i
      end
    end
  end

  def can_be_viewed_by?(user)
    visit.can_be_viewed_by?(user)
  end
end
