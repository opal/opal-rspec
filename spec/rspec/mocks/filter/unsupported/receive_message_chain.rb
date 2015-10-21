rspec_filter 'receive_message_chain' do
  # throw not supported on Opal 0.8
  filter('receive_message_chain with only the expect syntax enabled works with and_throw').unless { at_least_opal_0_9? }
end
