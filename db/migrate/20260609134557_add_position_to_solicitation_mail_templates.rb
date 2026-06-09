class AddPositionToSolicitationMailTemplates < ActiveRecord::Migration[8.1]
  def change
    add_column :solicitation_mail_templates, :position, :integer

    up_only do
      template_class = Class.new(ActiveRecord::Base) do
        self.table_name = 'solicitation_mail_templates'
      end

      template_class.order(:id).each_with_index do |template, index|
        template.update_column(:position, index + 1)
      end
    end
  end
end
