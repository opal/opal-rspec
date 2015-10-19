rspec_filter 'have_attributes' do
  # https://github.com/opal/opal/pull/1136 - operators and method missing issues with a_value > < etc
  unless at_least_opal_0_9?
    filter('#have_attributes matcher expect(...).to have_attributes(with_one_attribute) expect(...).to have_attributes(key => matcher) fails with a clear message when the matcher does not match')
    filter('#have_attributes matcher expect(...).to have_attributes(with_one_attribute) expect(...).to have_attributes(key => matcher) provides a description')
    filter('#have_attributes matcher expect(...).to have_attributes(with_one_attribute) expect(...).to have_attributes(key => matcher) passes when the matchers match')
  end
end
