rspec_filter 'include' do
  # https://github.com/opal/opal/pull/1136 - operators and method missing issues with a_value > < etc
  filter('#include matcher Composing matchers with `include` expect(array).to include(matcher) works with comparison matchers').unless { at_least_opal_0_9? }
end
