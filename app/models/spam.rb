# == Schema Information
#
# Table name: spams
#
#  id         :bigint(8)        not null, primary key
#  email      :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_spams_on_email  (email) UNIQUE
#
class Spam < ApplicationRecord
  validates :email, presence: true, allow_blank: false, uniqueness: true
end
