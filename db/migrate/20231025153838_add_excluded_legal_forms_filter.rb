class AddExcludedLegalFormsFilter < ActiveRecord::Migration[7.0]
  def change
    add_column :match_filters, :excluded_legal_forms, :string, array: true

    # Transformation des filtres existants du niveau 1 vers le niveau 3
    up_only do

      # ["1"]
      MatchFilter.where(accepted_legal_forms: ["1"]).update_all(accepted_legal_forms: ["1000"])

      # ["5"]
      legal_forms_5 = [
        '5191', '5192', '5193', '5194', '5195', '5196',
        '5202', '5203',
        '5306', '5307', '5308', '5309', '5370', '5385',
        '5410', '5415', '5422', '5426', '5430', '5431', '5432', '5442', '5443', '5451', '5453', '5454', '5455', '5458', '5459', '5460', '5470', '5485', '5498', '5499',
        '5505', '5510', '5515', '5520', '5522', '5525', '5530', '5531', '5532', '5542', '5543', '5546', '5547', '5548', '5551', '5552', '5553', '5554', '5555', '5558', '5559', '5560', '5570', '5585', '5599',
        '5605', '5610', '5615', '5620', '5622', '5625', '5630', '5631', '5632', '5642', '5643', '5646', '5647', '5648', '5651', '5652', '5653', '5654', '5655', '5658', '5659', '5660', '5670', '5685', '5699',
        '5710', '5720', '5770', '5785', '5800'
      ]
      MatchFilter.where(accepted_legal_forms: ["5"]).update_all(accepted_legal_forms: legal_forms_5)

      # ["2", "3", "4", "5", "6", "7", "8", "9"]
      MatchFilter
        .where(accepted_legal_forms: ["2", "3", "4", "5", "6", "7", "8", "9"]).or(
          MatchFilter.where(accepted_legal_forms: ["0", "2", "3", "4", "5", "6", "7", "8", "9"])
        ).update_all(accepted_legal_forms: [], excluded_legal_forms: ['1000'])
    end
  end
end
