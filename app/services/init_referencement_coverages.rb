# A supprimer une fois l'initialisation faite

class InitReferencementCoverages
  def initialize(antenne)
    @antenne = antenne
  end

  def call
    UpdateAntenneCoverage.new(@antenne).delay.call
    @antenne.territorial_antennes.each do |ta|
      UpdateAntenneCoverage.new(ta).delay.call
    end
  end
end
