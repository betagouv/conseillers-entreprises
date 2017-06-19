# frozen_string_literal: true

class MailtoLog < ApplicationRecord
  belongs_to :question
  belongs_to :visit
  belongs_to :assistance

  validates :question, :visit, presence: true
end
