require 'rspec/support/spec/stderr_splitter'

warning_preventer = $stderr = RSpec::Support::StdErrSplitter.new($stderr)

RSpec.configure do |c|
  c.include RSpecHelpers
  c.include RSpec::Support::WithIsolatedStdErr
  c.include RSpec::Support::FormattingSupport

  unless defined?(Debugger) # debugger causes warnings when used
    c.before do
      warning_preventer.reset!
    end

    c.after do |example|
      warning_preventer.verify_example!(example)
    end
  end

  if c.files_to_run.one?
    c.full_backtrace = true
    c.default_formatter = 'doc'
  end

  c.filter_run :focus
  c.run_all_when_everything_filtered = true
end
