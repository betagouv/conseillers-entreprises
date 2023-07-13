# A supprimer une fois l'initialisation faite

class InitReferencementCoverages
  def initialize(antenne)
    @antenne = antenne
  end

  def call
    UpdateAntenneCoverage.new(@antenne).call
    @antenne.territorial_antennes.each do |ta|
      UpdateAntenneCoverage.new(ta).call
    end
  end

end