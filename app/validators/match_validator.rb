class MatchValidator < ActiveModel::Validator
  def validate(match)
    if match.expert_skill && match.relay
      match.errors.add(:expert_skill, :can_not_be_set_with_relay)
    end
  end
end
