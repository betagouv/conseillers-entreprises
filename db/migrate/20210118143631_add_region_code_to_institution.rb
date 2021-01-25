class AddRegionCodeToInstitution < ActiveRecord::Migration[6.0]
  def change
    add_column :institutions, :code_region, :integer
    add_index :institutions, :code_region

    up_only do
      Institution.all.group_by(&:region_name).each do |region_name, institutions|
        next if region_name.nil?
        code_region = I18n.t("regions_slugs_to_codes.#{region_name.parameterize}")
        institutions.map { |i| i.update_columns(code_region: code_region) }
      end
    end

    remove_column :institutions, :region_name, :string
  end
end
