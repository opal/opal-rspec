# Opal does not support ObjectSpace, so force object __id__'s
class RSpec::Mocks::Space
  OPAL_NON_MOCKABLE_TYPES = [:String, :Number, :Numeric]

  def id_for(object)
    object.__id__
  end

  # originally had an alternate impl here due to Opal::RSpec::Compatibility.module_case_works_right?, now also doing checks
  def proxy_not_found_for(id, object)
    raise "#{object.class} #{object} cannot be used for mocking in Opal!" if OPAL_NON_MOCKABLE_TYPES.include?(object.class.name)
    # case when SomeClass wasn't working properly
    includes_test_double = [
        InstanceVerifyingDouble,
        ObjectVerifyingDouble,
        ClassVerifyingDouble,
        Double
    ]
    proxies[id] = if object.is_a?(NilClass)
                    ProxyForNil.new(@expectation_ordering)
                  elsif includes_test_double.any? { |klass| object.is_a? klass }
                    object.__build_mock_proxy_unless_expired(@expectation_ordering)
                  elsif object.is_a?(Class)
                    if RSpec::Mocks.configuration.verify_partial_doubles?
                      VerifyingPartialClassDoubleProxy.new(self, object, @expectation_ordering)
                    else
                      PartialClassDoubleProxy.new(self, object, @expectation_ordering)
                    end
                  else
                    if RSpec::Mocks.configuration.verify_partial_doubles?
                      VerifyingPartialDoubleProxy.new(object, @expectation_ordering)
                    else
                      PartialDoubleProxy.new(object, @expectation_ordering)
                    end
                  end
  end
end
