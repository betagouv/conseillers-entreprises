class AddCategoryToFeedback < ActiveRecord::Migration[6.0]
  def change
    categories = %w[need reminder solicitation]
    create_enum "feedbacks_categories", categories
    add_column :feedbacks, :category, :feedbacks_categories
    add_index :feedbacks, :category

    up_only do
      Feedback.where(feedbackable_type: 'Need').update_all(category: 'need')
      Feedback.where(feedbackable_type: 'Solicitation').update_all(category: 'solicitation')
    end

    change_column :feedbacks, :category, :feedbacks_categories, null: false
  end
end
