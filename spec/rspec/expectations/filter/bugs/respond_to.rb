rspec_filter 'respond_to' do
  # Also arity related, but looks like opal is returning the optional arg splat as arity
  filter 'expect(...).to respond_to(:sym).with(2).arguments passes if target responds to any number of arguments'

  # arity related
  filter('expect(...).to respond_to(:sym).with(1).argument passes if target responds to any number of arguments').if { at_least_opal_0_9? }
  filter('expect(...).to respond_to(:sym).with(2).arguments passes if target responds to one or more arguments').if { at_least_opal_0_9? }
  filter('expect(...).not_to respond_to(:sym).with(1).argument fails if target responds to :sym with any number of args').if { at_least_opal_0_9? }
  filter('expect(...).not_to respond_to(:sym).with(2).arguments fails if target responds to :sym with one or more args').if { at_least_opal_0_9? }
end
