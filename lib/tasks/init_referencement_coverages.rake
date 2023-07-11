desc 'init referencement coverages'
task init_referencement_coverages: :environment do
  Antenne.territorial_level_regional.each do |antenne|
    InitRegionalCoverage.new(antenne).delay(queue: :low_priority).call
  end
end

class InitRegionalCoverage
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
