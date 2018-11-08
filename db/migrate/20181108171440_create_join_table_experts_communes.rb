class CreateJoinTableExpertsCommunes < ActiveRecord::Migration[5.2]
  def up
    create_join_table :communes, :experts,
      column_options: {
        index: true,
        foreign_key: true
      }

    Expert.find_each do |expert|
      territories_communes = Commune.distinct
        .joins(territories: :experts)
        .where('experts.id = ?', expert)
      antenne_communes = expert.antenne.communes
      if territories_communes.pluck(:id).to_set == antenne_communes.pluck(:id).to_set
        puts "skipped #{expert.id}"
        expert.communes = []
      else
        expert.communes = territories_communes
      end
    end
  end

  def down
    drop_join_table :communes, :experts
  end
end
