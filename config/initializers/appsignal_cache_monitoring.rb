# Because AppSignal doesn't automatically derive a hit/miss ratio from the active_support events,
# let’s add a counter ourselves.
ActiveSupport::Notifications.subscribe("cache_read.active_support") do |*args|
  event = ActiveSupport::Notifications::Event.new(*args)
  if event.payload[:hit]
    Appsignal.increment_counter("cache.hit", 1)
  else
    Appsignal.increment_counter("cache.miss", 1)
  end
end
