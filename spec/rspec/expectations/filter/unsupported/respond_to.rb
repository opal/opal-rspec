rspec_filter 'respond_to' do
  filter('expect(...).not_to respond_to(:sym).with(2).arguments fails if target responds to :sym with any number args')
end
