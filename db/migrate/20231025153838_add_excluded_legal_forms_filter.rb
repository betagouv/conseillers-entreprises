class AddExcludedLegalFormsFilter < ActiveRecord::Migration[7.0]
  def change
    add_column :match_filters, :excluded_legal_forms, :string, array: true

    # Transformation des filtres existants du niveau 1 vers le niveau 3
    up_only do

      # ["1"]
      MatchFilter.where(accepted_legal_forms: ["1"]).update_all(accepted_legal_forms: ["1000"])

      # ["5"]
      legal_forms_5 = ['5710']
      MatchFilter.where(accepted_legal_forms: ["5"]).update_all(accepted_legal_forms: legal_forms_5)

      # ["2", "3", "4", "5", "6", "7", "8", "9"]
      MatchFilter
        .where(accepted_legal_forms: ["2", "3", "4", "5", "6", "7", "8", "9"]).or(
          MatchFilter.where(accepted_legal_forms: ["0", "2", "3", "4", "5", "6", "7", "8", "9"])
        ).update_all(accepted_legal_forms: [], excluded_legal_forms: ['1000'])
    end
  end
end
