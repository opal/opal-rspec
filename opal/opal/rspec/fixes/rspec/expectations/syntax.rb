unless Opal::RSpec::Compatibility.undef_within_exec_works?
  module ::RSpec::Expectations::Syntax
    def disable_expect(syntax_host=::RSpec::Matchers)
      return unless expect_enabled?(syntax_host)

      # undef not working on Opal 0.8
      # syntax_host.module_exec do
      #   undef expect
      # end
      syntax_host.remove_method(:expect)
    end

    def disable_should(syntax_host=default_should_host)
      return unless should_enabled?(syntax_host)

      # undef not working on Opal 0.8
      # syntax_host.module_exec do
      #   undef should
      #   undef should_not
      # end
      syntax_host.remove_method(:should)
      syntax_host.remove_method(:should_not)
    end
  end
end
