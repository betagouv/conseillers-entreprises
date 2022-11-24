class AddNafLibelleA10ToFacilities < ActiveRecord::Migration[6.0]
  def change
    add_column :facilities, :naf_code_a10, :string

    up_only do
      naf_codes = Facility.distinct.pluck(:naf_code)
      naf_codes.each do |naf_code|
        next if naf_code.nil?
        Facility.where(naf_code: naf_code).update_all(naf_code_a10: NafCode.code_a10(naf_code))
      end
    end
  end
end
