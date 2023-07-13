desc 'Init match sent_at'
task init_match_sent_at: :environment do

  Match.where(id: Match.joins(:diagnosis).merge(Diagnosis.step_completed)).where(sent_at: nil).find_in_batches(batch_size: 300) do |matches|
    matches.each do |match|
      match.update_columns(sent_at: match.diagnosis.completed_at)
    end
  end
end
