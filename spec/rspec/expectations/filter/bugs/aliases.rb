rspec_filter 'aliases' do
  unless at_least_opal_0_9?
    # Opal is interpretting the == and === literally (as a boolean)
    filter 'RSpec::Matchers should have an alias for "be == 3" with description: "a value == 3"'
    filter 'RSpec::Matchers should have an alias for "be === 3" with description: "a value === 3"'

    # https://github.com/opal/opal/pull/1136 - operators and method missing issues with a_value > < etc
    # These are the specify matchers inside aliases_spec and they are poorly named, our rake task gives them a name for us
    filter 'RSpec::Matchers alias example 6'
    filter 'RSpec::Matchers alias example 7'
    filter 'RSpec::Matchers alias example 8'
  end
end
