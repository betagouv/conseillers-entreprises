class AddAbTestingFields < ActiveRecord::Migration[6.1]
  def change
    add_column :solicitations, :completion_step, :integer
    up_only do
      Solicitation.incomplete.each do |sol|
        if sol.siret.blank?
          sol.update(completion_step: :contact)
        elsif sol.description.blank?
          sol.update(completion_step: :company)
        end
      end
    end
  end
end
