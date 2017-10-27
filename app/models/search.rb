# frozen_string_literal: true

class Search < ApplicationRecord
  belongs_to :user

  validates :user, presence: true

  scope :of_user, (->(user) { where(user: user) })
  scope :recent, (-> { order(created_at: :desc).limit(30) })
end
