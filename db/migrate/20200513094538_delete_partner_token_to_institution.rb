class DeletePartnerTokenToInstitution < ActiveRecord::Migration[6.0]
  def change
    solicitations = Solicitation.select { |s| s.form_info['partner_token'] == '128' if s.form_info.present? }
    solicitations.each do |solicitation|
      solicitation.form_info['institution_slug'] = 'conseil_regional_hauts_de_france'
      solicitation.form_info.delete('partner_token')
      solicitation.save!
    end

    remove_column :institutions, :partner_token, :string
  end
end
