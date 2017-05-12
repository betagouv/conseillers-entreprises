# frozen_string_literal: true

class Search < ApplicationRecord
  belongs_to :user

  validates :user, presence: true

  scope :last_queries_of_user, (->(user) { where(user: user).order(created_at: :desc).pluck(:query).uniq })
end
