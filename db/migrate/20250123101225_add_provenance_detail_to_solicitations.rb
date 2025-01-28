class AddProvenanceDetailToSolicitations < ActiveRecord::Migration[7.2]
  def change
    add_column :solicitations, :provenance_detail, :string

    up_only do
      InitSolicitationsProvenanceDetailJob.perform_later
    end
  end
end
