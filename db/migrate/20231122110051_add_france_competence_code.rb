class AddFranceCompetenceCode < ActiveRecord::Migration[7.0]
  def change
    add_column :institutions, :france_competence_code, :string
    up_only do
      [
        { siren: "784714008", code: "01" }, # Afdas
        { siren: "853000982", code: "02" }, # Akto
        { siren: "851296632", code: "03" }, # Atlas
        { siren: "533846150", code: "04" }, # Constructys
        { siren: "844752006", code: "05" }, # Ocapiat
        { siren: "879036895", code: "06" }, # EP
        { siren: "851240499", code: "07" }, # Mobilite
        { siren: "854033115", code: "08" }, # Opco santé
        { siren: "849813852", code: "09" }, # Opco 2i
        { siren: "398522243", code: "10" }, # Opcommerce
        { siren: "309065043", code: "11" }, # Uniformation
      ].each do |siren_and_code|
        Institution.where(siren: siren_and_code[:siren]).update_all(france_competence_code: siren_and_code[:code])
      end
    end
  end
end
