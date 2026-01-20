class AddInseeCodeToSolicitations < ActiveRecord::Migration[7.2]
  def up
    add_column :solicitations, :insee_code, :string

    # Backfill insee_code for in_progress solicitations that have a location but no insee_code
    solicitations_to_update = Solicitation.where(status: :in_progress)
      .where.not(location: [nil, ''])
      .where(insee_code: nil)

    say "Backfilling insee_code for #{solicitations_to_update.count} in_progress solicitations..."

    solicitations_to_update.find_each do |solicitation|
      normalized_location = normalize_string(solicitation.location)
      commune = DecoupageAdministratif::Commune.all.find do |c|
        normalize_string(c.nom).include?(normalized_location)
      end
      solicitation.update_column(:insee_code, commune.code) if commune.present?
    end
  end

  private

  def normalize_string(str)
    I18n.transliterate(str)
      .downcase
      .gsub(/[^a-z0-9]+/, ' ')
      .strip
  end

  def down
    remove_column :solicitations, :insee_code
  end
end
