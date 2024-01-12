class AddChildrenAntennes < ActiveRecord::Migration[7.0]
  def change
    add_reference :antennes, :parent_antenne, references: :antennes, index: true

    up_only do
      Antenne.not_deleted.territorial_level_regional.find_each do |regional_antenne|
        p "antenne regionale : #{regional_antenne.name} (#{regional_antenne.id}) ========================"
        institution_id = regional_antenne.institution_id
        
        territorial_antennes = Antenne.not_deleted.where(institution_id: institution_id, territorial_level: Antenne.territorial_levels[:local])
        .left_joins(:communes, :experts)
        .where(communes: { id: regional_antenne.commune_ids })
        .or(Antenne.not_deleted.where(institution_id: institution_id, territorial_level: Antenne.territorial_levels[:local]).where(experts: { is_global_zone: true }))
        .distinct
        p "Problème antennes territoriale !!!" if territorial_antennes.empty?
        territorial_antennes.update_all(parent_antenne_id: regional_antenne.id) if territorial_antennes.any?
        
        national_antenne = Antenne.not_deleted.where(institution_id: regional_antenne.institution_id, territorial_level: :national).first
        p "Problème antenne nationale !!!" if national_antenne.blank?
        regional_antenne.update(parent_antenne_id: national_antenne.id) if national_antenne.present?
      end
    end
  end
end
