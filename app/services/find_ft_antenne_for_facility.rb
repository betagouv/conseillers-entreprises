class FindFtAntenneForFacility

  # def initialize(facility)
  #   @facility = facility
  # end

  def initialize; end

  def call
    # file = File.read(Rails.root.join('tmp', 'extrait_FT_02.csv'))
    # file = File.read(Rails.root.join('tmp', 'Affectation_FT_des_SIRET_Nov2024.csv'))
    file = File.open(Rails.root.join('tmp', 'siret_FT_aa'))
    codes_safir = []
    CSV.foreach(file, headers: true, col_sep: ";") do |row|
      codes_safir << row['code_safir_structure'] 
    end
    byebug
    p codes_safir.sort.uniq
  end

  private
end
