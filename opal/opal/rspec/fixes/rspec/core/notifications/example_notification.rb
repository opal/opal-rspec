unless Opal::RSpec::Compatibility.constant_resolution_from_struct?
  class ::RSpec::Core::Notifications::ExampleNotification
    Formatters = ::RSpec::Core::Formatters
    SkippedExampleNotification = ::RSpec::Core::Notifications::SkippedExampleNotification
    PendingExampleFixedNotification = ::RSpec::Core::Notifications::PendingExampleFixedNotification
    PendingExampleFailedAsExpectedNotification = ::RSpec::Core::Notifications::PendingExampleFailedAsExpectedNotification
    FailedExampleNotification = ::RSpec::Core::Notifications::FailedExampleNotification
  end
end
