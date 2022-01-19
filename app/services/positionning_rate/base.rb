module PositionningRate::Base
  # Taux critique : + de 70% des besoins sont encore en attente
  CRITICAL_RATE = 0.70
  WORRYING_RATE = 0.40
  DEFAULT_START_DATE = 60.days.ago
  DEFAULT_END_DATE = Time.zone.now
end
