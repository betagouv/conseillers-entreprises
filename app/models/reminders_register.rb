# == Schema Information
#
# Table name: reminders_registers
#
#  id         :bigint(8)        not null, primary key
#  basket     :integer
#  category   :integer          default("remainder"), not null
#  processed  :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expert_id  :bigint(8)        not null
#
# Indexes
#
#  index_reminders_registers_on_expert_id  (expert_id)
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#
class RemindersRegister < ApplicationRecord
  belongs_to :expert

  MATCHES_AGE = {
    quo: 15.days.ago,
    done: 3.months.ago
  }

  MATCHES_COUNT = {
    quo: 2,
    many: 5,
    medium: 2
  }

  TIME_GENERATION = 1.week

  enum category: { remainder: 0, input: 1, output: 2 }, _suffix: true
  enum basket: { many_pending_needs: 0, medium_pending_needs: 1, one_pending_need: 2 }, _suffix: true
  # current_remainder_category = dans les paniers sauf inputs et outputs
  scope :current_remainder_category, -> {
  where(created_at: TIME_GENERATION.ago.., category: :remainder)
    .or(RemindersRegister.where(created_at: TIME_GENERATION.ago.., category: :input, processed: true))
    .distinct
}
  scope :current_input_category, -> { input_category.where(created_at: TIME_GENERATION.ago.., processed: false) }
  scope :current_output_category, -> { output_category.where(processed: false) }
end
