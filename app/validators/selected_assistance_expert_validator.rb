class SelectedAssistanceExpertValidator < ActiveModel::Validator
  def validate(selected_assistance_expert)
    if selected_assistance_expert.assistance_expert && selected_assistance_expert.territory_user
      selected_assistance_expert.errors.add(:assistance_expert, :can_not_be_set_with_territory_user)
    end
  end
end
