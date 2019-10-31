class RemoveFeedbackMatch < ActiveRecord::Migration[5.2]
  def change
    remove_reference :feedbacks, :match, foreign_key: true
  end
end
