# == Schema Information
#
# Table name: reminders_registers
#
#  id         :bigint(8)        not null, primary key
#  basket     :integer
#  category   :integer          default("remainder"), not null
#  processed  :boolean          default(FALSE), not null
#  run_number :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  expert_id  :bigint(8)        not null
#
# Indexes
#
#  index_reminders_registers_on_expert_id                 (expert_id)
#  index_reminders_registers_on_run_number_and_expert_id  (run_number,expert_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (expert_id => experts.id)
#
class RemindersRegister < ApplicationRecord
  belongs_to :expert

  validates :run_number, presence: true, uniqueness: { scope: :expert_id }

  enum category: { remainder: 0, input: 1, output: 2 }, _suffix: true
  enum basket: { many_pending_needs: 0, medium_pending_needs: 1, one_pending_need: 2 }, _suffix: true

  # current_remainder_category = dans les paniers sauf inputs et outputs
  scope :current_remainder_category, -> {
    where(run_number: RemindersRegister.last_run_number, category: :remainder)
      .or(RemindersRegister.where(run_number: RemindersRegister.last_run_number, category: :input, processed: true))
      .distinct
  }
  scope :current_input_category, -> { input_category.where(run_number: RemindersRegister.last_run_number, processed: false) }
  scope :current_output_category, -> { output_category.where(run_number: RemindersRegister.last_run_number, processed: false) }

  def self.last_run_number
    RemindersRegister.pluck(:run_number).max
  end

  def current_reminder_register
    expert.reminders_registers.current_input_category.first
  end
end
