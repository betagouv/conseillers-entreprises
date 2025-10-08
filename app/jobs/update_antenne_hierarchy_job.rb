class UpdateAntenneHierarchyJob
  include Sidekiq::Job

  # Updated when changed : add/remove communes
  def perform(antenne_id)
    antenne = Antenne.find_by(id: antenne_id)
    return unless antenne
    AntenneHierarchy.new(antenne).call
  end
end
