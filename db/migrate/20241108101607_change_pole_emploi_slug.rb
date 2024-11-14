class ChangePoleEmploiSlug < ActiveRecord::Migration[7.0]
  def up
    Institution.find_by(slug: 'pole-emploi')&.update(slug: 'france-travail')
  end

  def down
    Institution.find_by(slug: 'france-travail')&.update(slug: 'pole-emploi')
  end
end
