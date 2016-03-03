rspec_filter 'stub implementation' do
  # stubs class methods
  filter('unstubbing with `and_call_original` when partial doubles are not verified restores the correct implementations when stubbed and unstubbed on a grandparent and grandchild class')
  filter('unstubbing with `and_call_original` when partial doubles are not verified restores the correct implementations when stubbed and unstubbed on a parent and child class')
end
