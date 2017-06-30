# frozen_string_literal: true

class AssistanceExpert < ApplicationRecord
  belongs_to :assistance
  belongs_to :expert
end
