module WithEffectif
  # https://www.sirene.fr/sirene/public/variable/tefen
  #
  extend ActiveSupport::Concern

  def intitule_effectif
    Effectif::CodeEffectif.new(self.code_effectif).intitule_effectif
  end
end
