task init_match_sent_at: :environment do
  Match.sent.where(sent_at: nil).find_in_batches(batch_size: 1000) do |matches|
    InitMatchSentAt.new(matches).delay(queue: :low_priority).call
  end
end

class InitMatchSentAt
  def initialize(matches)
    @matches = matches
  end

  def call
    @matches.each do | match|
      match.update_columns(sent_at: match.diagnosis.completed_at)
    end
  end
end
