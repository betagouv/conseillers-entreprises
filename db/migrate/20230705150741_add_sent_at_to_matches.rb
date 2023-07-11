class AddSentAtToMatches < ActiveRecord::Migration[7.0]
  def change
    add_column :matches, :sent_at, :timestamp

    up_only do
      # on fait le reste en batch, en console
      Match.sent.created_between(3.months.ago, Time.zone.now).where(sent_at: nil).find_each do |match|
        match.update_columns(sent_at: match.diagnosis.completed_at)
      end
    end
  end
end
