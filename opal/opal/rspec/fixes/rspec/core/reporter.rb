class RSpec::Core::Reporter
  # https://github.com/opal/opal/issues/858
  # The problem is not directly related to the Reporter class (it has more to do with Formatter's call in add using a splat in the args list and right now, Opal does not run a to_a on a splat before the callee method takes over)
  def register_listener(listener, *notifications)
    # Without this, we won't flatten out each notification properly (e.g. example_started, finished, etc.)
    notifications = notifications[0].to_a unless notifications[0].is_a? Array
    notifications.each do |notification|
      @listeners[notification.to_sym] << listener
    end
    true
  end
end
