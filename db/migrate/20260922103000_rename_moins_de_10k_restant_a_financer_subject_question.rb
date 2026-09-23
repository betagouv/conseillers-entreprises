class RenameMoinsDe10kRestantAFinancerSubjectQuestion < ActiveRecord::Migration[8.1]
  def up
    SubjectQuestion.where(key: 'moins_de_10k_restant_a_financer')
      .update_all(key: 'moins_de_20k_restant_a_financer')
  end

  def down
    SubjectQuestion.where(key: 'moins_de_20k_restant_a_financer')
      .update_all(key: 'moins_de_10k_restant_a_financer')
  end
end
