module WithEffectif
  # https://www.sirene.fr/sirene/public/variable/tefen
  #
  extend ActiveSupport::Concern

  def intitule_effectif
    Effectif::CodeEffectif.new(self.code_effectif).intitule_effectif
  end

  def displayable_code_effectif
    if [nil, 'NR', 'NN'].include?(self.code_effectif)
      return '00'
    else
      return self.code_effectif
    end
  end
end
