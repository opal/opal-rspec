rspec_filter 'stderr_splitter' do
  # Tries to execute #stat on IO
  filter 'RSpec::Support::StdErrSplitter supports methods that stderr supports but StringIO does not'

  # also don't have this
  filter 'RSpec::Support::StdErrSplitter supports #to_io'
end
