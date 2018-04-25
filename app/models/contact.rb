# frozen_string_literal: true

class Contact < ApplicationRecord
  include PersonConcern

  belongs_to :company
  has_many :visits, foreign_key: 'visitee_id', dependent: :restrict_with_error

  validates :company, presence: true
  validates_with ContactValidator

  scope :ordered_by_names, (-> { order(:first_name, :last_name) })

  def can_be_viewed_by?(user)
    visits.any? { |visit| visit.can_be_viewed_by?(user) }
  end

  def full_name=(full_name)
    return unless full_name
    split_full_name = full_name.split(' ')
    return if split_full_name.count.zero?
    case split_full_name.count
    when 1
      self.last_name = split_full_name[0]
    else
      self.first_name = split_full_name[0]
      self.last_name = split_full_name[1..-1].join(' ')
    end
  end
end
