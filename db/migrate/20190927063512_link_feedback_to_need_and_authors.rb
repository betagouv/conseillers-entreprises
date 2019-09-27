class LinkFeedbackToNeedAndAuthors < ActiveRecord::Migration[5.2]
  def up
    add_reference :feedbacks, :need, foreign_key: true
    add_reference :feedbacks, :expert, foreign_key: true
    add_reference :feedbacks, :user, foreign_key: true

    # Copy expert and need ids from the match to the new columns.
    Feedback.connection.execute('UPDATE feedbacks SET need_id = matches.need_id, expert_id = matches.expert_id FROM matches where feedbacks.match_id = matches.id')

    # We shouldn’t be using the match column anymore, but let’s keep it around for a while.
    change_column_null :feedbacks, :match_id, true

    # Now we can make the need column nonnull.
    change_column_null :feedbacks, :need_id, null: false
  end

  def down
    remove_reference :feedbacks, :need
    remove_reference :feedbacks, :expert
    remove_reference :feedbacks, :user

    change_column_null :feedbacks, :match_id, false
  end
end
