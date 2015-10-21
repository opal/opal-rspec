rspec_filter 'respond_to' do
  # arity
  filter('expect(...).not_to respond_to(:sym).with(2).arguments fails if target responds to :sym with two or more args').unless { at_least_opal_0_9? }
  filter('expect(...).not_to respond_to(:sym).with(2).arguments fails if target responds to :sym with any number args')
end
