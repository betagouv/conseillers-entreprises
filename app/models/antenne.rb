class Antenne < ApplicationRecord
  belongs_to :institution
  has_and_belongs_to_many :communes, join_table: :intervention_zones

  validates :name, presence: true, uniqueness: true
  validates :institution, presence: true
end
