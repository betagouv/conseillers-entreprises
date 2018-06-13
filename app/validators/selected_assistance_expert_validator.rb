class SelectedAssistanceExpertValidator < ActiveModel::Validator
  def validate(match)
    if match.assistance_expert && match.relay
      match.errors.add(:assistance_expert, :can_not_be_set_with_relay)
    end
  end
end
