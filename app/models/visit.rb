# frozen_string_literal: true

class Visit < ApplicationRecord
  belongs_to :advisor, class_name: 'User'
  belongs_to :visitee, class_name: 'User'

  validates :happened_at, :siret, :advisor, presence: true
end
