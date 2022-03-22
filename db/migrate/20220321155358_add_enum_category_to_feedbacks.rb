class AddEnumCategoryToFeedbacks < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def up
    add_enum_value :feedbacks_categories, "expert_reminder"
    rename_enum_value :feedbacks_categories, "reminder", "need_reminder"

    ActiveRecord::Base.transaction do
      pde_user = User.admin.find(3174)
      Expert.where.not(reminders_notes: [nil, '']).each do |expert|
        rf = expert.reminder_feedbacks.create(
          user: pde_user,
          description: expert.reminders_notes
        )
      end

      remove_column :experts, :reminders_notes, :text
    end
  end

  def down
    ActiveRecord::Base.transaction do
      add_column :experts, :reminders_notes, :text

      Feedback.category_expert_reminder.each do |feedback|
        feedback.feedbackable.update(reminders_notes: feedback.description)
      end
    end

    rename_enum_value :feedbacks_categories, "need_reminder", "reminder"
    remove_enum_value :feedbacks_categories, "expert_reminder"
  end
end
