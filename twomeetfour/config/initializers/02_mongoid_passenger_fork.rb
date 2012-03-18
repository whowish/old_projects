if defined?(PhusionPassenger)
  PhusionPassenger.on_event(:starting_worker_process) do |forked|
    Rails.logger.info { "Passenger forked"}
    if forked
      Rails.logger.info { "Reconnected" }
      Mongoid.reconnect!
    end
  end
end