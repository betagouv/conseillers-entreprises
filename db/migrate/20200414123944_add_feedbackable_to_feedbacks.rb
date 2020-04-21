class AddFeedbackableToFeedbacks < ActiveRecord::Migration[6.0]
  def up
    add_reference :feedbacks, :feedbackable, polymorphic: true
    Feedback.all.each do |feedback|
      feedback.update(feedbackable_id: feedback.need_id, feedbackable_type: 'Need')
    end
    remove_column :feedbacks, :need_id
  end

  def down
    add_reference :feedbacks, :need, foreign_key: true
    Feedback.all.each do |feedback|
      feedback.update(need_id: feedback.feedbackable_id)
    end
    remove_column :feedbacks, :feedbackable_id
    remove_column :feedbacks, :feedbackable_type
  end
end
