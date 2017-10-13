# frozen_string_literal: true

class DiagnosedNeed < ApplicationRecord
  belongs_to :diagnosis
  belongs_to :question

  has_many :selected_assistance_experts

  validates :diagnosis, presence: true

  scope :of_diagnosis, (->(diagnosis) { where(diagnosis: diagnosis) })
  scope :of_question, (->(question) { where(question: question) })
  scope :with_at_least_one_expert_done, (lambda do
    where(id: SelectedAssistanceExpert.with_status(:done).select(:diagnosed_need_id))
  end)
end
