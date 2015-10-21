# RSpec::Core::ExampleGroup setting pending metadata in parent marks every example as pending
# This opal-rspec test failure is happening because 'fail' in opal does not behave correctly
# https://github.com/opal/opal/pull/1117, status pending
unless Opal::RSpec::Compatibility.fail_raise_matches_mri?
  module Kernel
    def fail(message=nil)
      if message
        raise message
      else
        raise RuntimeError.new
      end
    end
  end
end

# https://github.com/opal/opal/issues/1110, fixed in Opal 0.9
unless Opal::RSpec::Compatibility.class_within_class_new_works?
  class ::RSpec::Core::HooksHost
    include Hooks

    def parent_groups
      []
    end
  end
end

# Fixed in Opal 0.9
# https://github.com/opal/opal/commit/a6ec3164fcbb0f98ef46d385ea06bf0591828f23)
unless Object.const_defined? :ZeroDivisionError
  class ZeroDivisionError < StandardError
  end
end

# https://github.com/opal/opal/commit/5a17a12de1d3af45e189d34994a047fb7c1b4c72
unless Object.const_defined? :SecurityError
  class SecurityError < Exception
  end
end
