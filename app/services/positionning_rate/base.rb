module PositionningRate::Base
  # Taux critique : + de 70% des besoins sont encore en attente
  CRITICAL_RATE = 0.70
  WORRYING_RATE = 0.40
  DEFAULT_START_DATE = Time.zone.now - 60.days
  DEFAULT_END_DATE = Time.zone.now
end
