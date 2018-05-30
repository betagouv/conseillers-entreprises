class SelectedAssistanceExpertValidator < ActiveModel::Validator
  def validate(selected_assistance_expert)
    if selected_assistance_expert.assistance_expert && selected_assistance_expert.relay
      selected_assistance_expert.errors.add(:assistance_expert, :can_not_be_set_with_relay)
    end
  end
end
