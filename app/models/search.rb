# == Schema Information
#
# Table name: searches
#
#  id         :integer          not null, primary key
#  label      :string
#  query      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#
# Indexes
#
#  index_searches_on_query    (query)
#  index_searches_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Search < ApplicationRecord
  ## Associations
  #
  belongs_to :user, inverse_of: :searches

  ## Validations
  #
  validates :user, presence: true
  validates :query, presence: true

  ## Scopes
  #
  scope :recent, (-> { order(created_at: :desc).limit(30) })

  ##
  #
  def summary
    if label.present?
      "#{label} (#{query})"
    else
      query
    end
  end
end
