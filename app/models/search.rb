# frozen_string_literal: true

class Search < ApplicationRecord
  belongs_to :user

  validates :user, presence: true

  scope :recent, (-> { order(created_at: :desc).limit(30) })

  def summary
    label || query
  end
end
