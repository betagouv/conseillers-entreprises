class AddLogoForLesClubsSportifEngages < ActiveRecord::Migration[7.2]
  def change
    cooperation = Cooperation.find_by(name: 'Les clubs sportifs engagés')
    Logo.create!(
      logoable: cooperation,
      filename: 'les-clubs-sportifs-engages',
      name: 'Les clubs sportifs engagés'
    ) if cooperation.present?
  end
end
