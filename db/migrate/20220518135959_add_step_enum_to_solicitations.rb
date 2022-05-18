class AddStepEnumToSolicitations < ActiveRecord::Migration[7.0]
  def up
    Solicitation.where.not(description: nil).update_all(completion_step: :completed)
    Solicitation.where(completion_step: [:contact, :company, :description]).each do |sol|
      new_step = Solicitation.completion_steps.key(Solicitation.completion_steps[sol.completion_step] + 1)
      sol.update(completion_step: new_step)
    end
    change_column_default :solicitations, :completion_step, from: nil, to: 0
  end

  def down
    change_column_default :solicitations, :completion_step, from: 0, to: nil
    Solicitation.where(completion_step: [:company, :description]).each do |sol|
      new_step = Solicitation.completion_steps.key(Solicitation.completion_steps[sol.completion_step] - 1)
      sol.update(completion_step: new_step)
    end
  end
end
