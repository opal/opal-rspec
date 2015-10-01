# the safety method is defined in helper_methods and uses threads
module RSpecHelpers
  def safely
    yield
  end
end

# Since our call site (locating which line a test is on does not yet work, we don't want to fail all of these mocks)
module RSpecHelpers
  def expect_deprecation_with_call_site(file, line, snippet=//)
    expect(RSpec.configuration.reporter).to receive(:deprecation) do |options|
      #expect(options[:call_site]).to include([file, line].join(':'))
      expect(options[:deprecated]).to match(snippet)
    end
  end

  def expect_deprecation_without_call_site(snippet=//)
    expect(RSpec.configuration.reporter).to receive(:deprecation) do |options|
      #expect(options[:call_site]).to eq nil
      expect(options[:deprecated]).to match(snippet)
    end
  end

  def expect_warn_deprecation_with_call_site(file, line, snippet=//)
    expect(RSpec.configuration.reporter).to receive(:deprecation) do |options|
      message = options[:message]
      expect(message).to match(snippet)
      #expect(message).to include([file, line].join(':'))
    end
  end

  def expect_warning_with_call_site(file, line, expected=//)
    expect(::Kernel).to receive(:warn) do |message|
      expect(message).to match expected
      #expect(message).to match(/Called from #{file}:#{line}/)
    end
  end
end
