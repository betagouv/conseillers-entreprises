class AddChildrenAntennes < ActiveRecord::Migration[7.0]
  def change
    add_reference :antennes, :parent_antenne, references: :antennes, index: true

    up_only do
      Antenne.not_deleted.territorial_level_regional.order(:institution_id).find_each do |regional_antenne|
        institution_id = regional_antenne.institution_id

        territorial_antennes = Antenne.not_deleted.where(institution_id: institution_id, territorial_level: :local)
          .left_joins(:communes, :experts)
          .where(communes: { id: regional_antenne.commune_ids })
          .or(Antenne.not_deleted.where(institution_id: institution_id, territorial_level: :local).where(experts: { is_global_zone: true }))
          .distinct
        territorial_antennes.update_all(parent_antenne_id: regional_antenne.id) if territorial_antennes.any?

        national_antenne = Antenne.not_deleted.where(institution_id: regional_antenne.institution_id, territorial_level: :national).first
        regional_antenne.update(parent_antenne_id: national_antenne.id) if national_antenne.present?
      end
    end
  end
end
