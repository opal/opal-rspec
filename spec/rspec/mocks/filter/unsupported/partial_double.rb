rspec_filter 'partial_double' do
  # not sure what broke this on 0.8. public_methods impl?
  filter('Method visibility when using partial mocks keeps public methods public').unless { at_least_opal_0_9? }
  filter 'Method visibility when using partial mocks keeps private methods private'
  filter 'Method visibility when using partial mocks keeps protected methods protected'
end
